#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

// --- Parameters ---
params.version = "2025-02-19"
// Major Unite version / data is not iterable by design, as I only run on new releases
params.taxon_group = ["fungi"]
// "fungi", "eukaryotes"
params.cluster_id = ["99", "97", "dynamic"]
params.singletons = [true, false]
params.derep_mode = ["super", "uniq"]
params.outdir = "./results"

// --- Workflow ---
workflow {
    log.info(
        """
        Q2 RESCRIPt UNITE Database Workflow
        ===================================
        version     : ${params.version}
        taxon_group : ${params.taxon_group}
        cluster_id  : ${params.cluster_id}
        singletons  : ${params.singletons}
        outdir      : ${params.outdir}
        """
    )

    // Create a channel for each parameter
    ch_version = channel.of(params.version)
    ch_taxon_group = channel.fromList(params.taxon_group)
    ch_cluster_id = channel.fromList(params.cluster_id)
    ch_singletons = channel.fromList(params.singletons)
    ch_derep_mode = channel.fromList(params.derep_mode)

    // Combine the channels to get all combinations
    ch_unite_params = ch_version
        .combine(ch_taxon_group)
        .combine(ch_cluster_id)
        .combine(ch_singletons)
        .combine(ch_derep_mode)

    // Note: As we move through the pipeline, we keep adding more elements to
    // the Main Tupple, to collate inputs and outputs.
    ch_unite_params.view()
    /*
    Prints:
        [2025-02-19, fungi, 99, true, super]
        [2025-02-19, fungi, 99, true, uniq]
        [2025-02-19, fungi, 99, false, super]
        [2025-02-19, fungi, 99, false, uniq]
        [2025-02-19, fungi, 97, true, super]
        [2025-02-19, fungi, 97, true, uniq]
        [2025-02-19, fungi, 97, false, super]
        [2025-02-19, fungi, 97, false, uniq]
    */

    // Note: Because we only have one Main Tupple, each step is easy!
    ch_unite_raw = GET_UNITE_DATA(ch_unite_params)
    ch_tax_edited = EDIT_TAXONOMY(ch_unite_raw)
    ch_tax_derep = DEREPLICATE(ch_tax_edited)
    ch_classifiers = FIT_CLASSIFIER_NB(ch_tax_derep)
    // ch_classifiers.view()

    // Run the original sequences through the new classifiers

    ch_reclassification = RE_CLASSIFY_SKLEARN(ch_classifiers)
    //ch_reclassification.view()

    // ch_evaluation = EVALUATE_CLASSIFICATIONS(ch_reclassification)
    // ch_evaluation.view()

    // 1. Map to extract strictly: [Expected_Path, Observed_Path, Label_String]
    // 2. Collect with flat: false to create a List of Lists: [[p1, p2, l1], [p1, p2, l2], ...]
    ch_inputs_collected = ch_reclassification
        .map { ver, tax, clust, sing, mode, _seq, _raw, edit, _classif, pred ->
            def s_str = sing ? "_s" : ""
            def label = "${ver}_${clust}${s_str}_${tax}_${mode}"
            // Return [Expected, Predicted, Label]
            return [edit, pred, label]
        }
        .collect(flat: false) 

    // 3. Transpose: Turn the "List of Triplets" into "Triplet of Lists"
    // Result: [ [exp1, exp2...], [obs1, obs2...], [lbl1, lbl2...] ]
    ch_final_eval_input = ch_inputs_collected.map { all_items ->
        def expected_list = all_items.collect { it[0] }
        def observed_list = all_items.collect { it[1] }
        def labels_list   = all_items.collect { it[2] }
        return [ expected_list, observed_list, labels_list ]
    }

    // 4. Run the combined process
    ALL_EVALUATE_CLASSIFICATIONS(ch_final_eval_input)

}


// --- Processes ---
process GET_UNITE_DATA {
    label 'qiime2'
    cpus 2
    // publishDir "${params.outdir}/raw_data", mode: 'copy', saveAs: { filename ->
    //     if (filename == "sequences.qza") {
    //         def s_str = singletons ? "_s" : ""
    //         return "unite_ver${version}_${cluster_id}${s_str}_${taxon_group}_sequences.qza"
    //     } else if (filename == "taxonomy.qza") {
    //         def s_str = singletons ? "_s" : ""
    //         return "unite_ver${version}_${cluster_id}${s_str}_${taxon_group}_taxonomy.qza"
    //     }
    //     // don't publish other files
    //     return null
    // }

    input:
    tuple val(version), val(taxon_group), val(cluster_id), val(singletons), val(derep_mode)

    output:
    tuple val(version), val(taxon_group), val(cluster_id), val(singletons), val(derep_mode), path("sequences.qza"), path("taxonomy.qza"), emit: unite_files

    script:
    def singleton_flag = singletons ? '--p-singletons' : '--p-no-singletons'
    """
    qiime rescript get-unite-data \\
        --p-version "${version}" \\
        --p-taxon-group "${taxon_group}" \\
        --p-cluster-id "${cluster_id}" \\
        ${singleton_flag} \\
        --o-sequences sequences.qza \\
        --o-taxonomy taxonomy.qza \\
        --verbose
    """
}

process EDIT_TAXONOMY {
    label 'qiime2'

    input:
    tuple val(version), val(taxon_group), val(cluster_id), val(singletons), val(derep_mode), path(sequences), path(taxonomy)

    output:
    tuple val(version), val(taxon_group), val(cluster_id), val(singletons), val(derep_mode), path(sequences), path(taxonomy), path("taxonomy-no-SH.qza"), emit: edit_taxonomy

    script:
    """
    qiime rescript edit-taxonomy \\
        --i-taxonomy ${taxonomy} \\
        --o-edited-taxonomy taxonomy-no-SH.qza \\
        --p-search-strings ';sh__.*' \\
        --p-replacement-strings '' \\
        --p-use-regex
    """
}

process DEREPLICATE {
    label 'qiime2'
    cpus 2

    input:
    tuple val(version), val(taxon_group), val(cluster_id), val(singletons), val(derep_mode), path(sequences), path(raw_taxonomy), path(edited_taxonomy)

    output:
    // Output structure mimics input so it flows into FIT_CLASSIFIER_NB:
    // sequences and edited_taxonomy are both from this drep step!
    tuple val(version), val(taxon_group), val(cluster_id), val(singletons), val(derep_mode), path("derep-sequences.qza"), path(raw_taxonomy), path("derep-taxonomy.qza"), emit: dereplicated

    script:
    """
    qiime rescript dereplicate \
        --i-sequences ${sequences} \
        --i-taxa ${edited_taxonomy} \
        --p-mode ${derep_mode} \
        --p-threads ${task.cpus} \
        --o-dereplicated-sequences derep-sequences.qza \
        --o-dereplicated-taxa derep-taxonomy.qza
    """
}

process FIT_CLASSIFIER_NB {
    label 'qiime2'
    publishDir "${params.outdir}/classifier", mode: 'copy', saveAs: { filename ->
        if (filename == "classifier.qza") {
            // Previous name: unite_ver10_99_s_all_19.02.2025-Q2-2024.10.qza
            def s_str = singletons ? "_s" : ""
            return "unite_ver${version}_${cluster_id}${s_str}_${taxon_group}_${derep_mode}-Q2-2026.1.qza"
        }
        // don't publish other files
        return null
    }
    cpus 8

    input:
    tuple val(version), val(taxon_group), val(cluster_id), val(singletons), val(derep_mode), path(sequences), path(taxonomy), path(taxonomy_edit)

    output:
    tuple val(version), val(taxon_group), val(cluster_id), val(singletons), val(derep_mode), path(sequences), path(taxonomy), path(taxonomy_edit), path("classifier.qza"), emit: classifier

    script:
    """
    qiime feature-classifier fit-classifier-naive-bayes \\
        --p-classify--chunk-size 2000 \\
        --i-reference-reads ${sequences} \\
        --i-reference-taxonomy ${taxonomy_edit} \\
        --o-classifier classifier.qza
    """
}

process RE_CLASSIFY_SKLEARN {
    label 'qiime2'
    cpus 8
    publishDir "${params.outdir}/evaluation", mode: 'copy', saveAs: { filename ->
        if (filename == "reclassification.qza") {
            def s_str = singletons ? "_s" : ""
            return "reclass_ver${version}_${cluster_id}${s_str}_${taxon_group}_${derep_mode}.qza"
        }
        return null
    }

    input:
    tuple val(version), val(taxon_group), val(cluster_id), val(singletons), val(derep_mode), path(sequences), path(taxonomy), path(taxonomy_edit), path(classifier)

    output:
    tuple val(version), val(taxon_group), val(cluster_id), val(singletons), val(derep_mode), path(sequences), path(taxonomy), path(taxonomy_edit), path(classifier), path("reclassification.qza"), emit: reclassification

    script:
    """
    qiime feature-classifier classify-sklearn \\
        --i-classifier ${classifier} \\
        --i-reads ${sequences} \\
        --p-n-jobs 1 \\
        --p-reads-per-batch 2000 \\
        --p-confidence 0 \\
        --o-classification reclassification.qza
    """
}

process EVALUATE_CLASSIFICATIONS {
    label 'qiime2'
    cpus 2

    publishDir "${params.outdir}/evaluation", mode: 'copy', saveAs: { filename ->
        if (filename == "evaluation.qzv") {
            def s_str = singletons ? "_s" : ""
            return "eval_ver${version}_${cluster_id}${s_str}_${taxon_group}.qzv"
        }
        return null
    }

    input:
    tuple val(version), val(taxon_group), val(cluster_id), val(singletons), val(derep_mode), path(sequences), path(tax_raw), path(tax_edit), path(classifier), path(tax_pred)

    output:
    tuple val(version), val(taxon_group), val(cluster_id), val(singletons), val(derep_mode), path("evaluation.qzv"), emit: evaluation

    script:
    """
    qiime rescript evaluate-classifications \\
        --i-expected-taxonomies ${tax_raw} ${tax_raw} \\
        --i-observed-taxonomies ${tax_edit} ${tax_pred} \\
        --p-labels 'no sh__' 'reclassified' \\
        --o-evaluation evaluation.qzv
    """
}

process ALL_EVALUATE_CLASSIFICATIONS {
    label 'qiime2'
    publishDir "${params.outdir}", mode: 'copy', saveAs: { filename ->
        if (filename == "evaluation.qzv") {
            return "eval_unite_ver${params.version}.qzv"
        }
        return null
    }

    input:
    // We stageAs with '*' to handle collisions
    tuple path(expected_taxonomies, stageAs: 'edit_tax_*.qza'), \
          path(observed_taxonomies, stageAs: 'pred_tax_*.qza'), \
          val(labels), val(derep_mode)

    output:
    path "evaluation.qzv"

    script:
    def label_str = labels.join(' ')
    """
    qiime rescript evaluate-classifications \\
        --i-expected-taxonomies ${expected_taxonomies} \\
        --i-observed-taxonomies ${observed_taxonomies} \\
        --p-labels ${label_str} \\
        --o-evaluation evaluation.qzv
    """
}

