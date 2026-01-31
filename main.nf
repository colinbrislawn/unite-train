#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

// --- Parameters ---
params.version = "2025-02-19"
params.taxon_group = ["fungi"]
// "fungi", "eukaryotes"
params.cluster_id = ["99", "97"]
// "99", "97", "dynamic"
params.singletons = [true, false]
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

    // Combine the channels to get all combinations
    ch_unite_params = ch_version
        .combine(ch_taxon_group)
        .combine(ch_cluster_id)
        .combine(ch_singletons)

    // Note: As we move through the pipeline, we keep adding more elements to
    // the Main Tupple, to collate inputs and outputs.
    ch_unite_params.view()
    /*
    Prints:
    [2025-02-19, fungi, 99, true]
    [2025-02-19, fungi, 99, false]
    [2025-02-19, fungi, 97, true]
    [2025-02-19, fungi, 97, false]
    */

    // Note: Because we only have one Main Tupple, each step is easy!
    ch_unite_raw = GET_UNITE_DATA(ch_unite_params)
    ch_tax_edited = EDIT_TAXONOMY(ch_unite_raw)
    ch_classifiers = FIT_CLASSIFIER_NB(ch_tax_edited)
    ch_classifiers.view()

    // [2025-02-19, fungi, 97, true, /Users/cbrisl/bin/git-repos/unite-train/work/35/1a72a2b0f2ec1daa4bdf505ea14871/sequences.qza, /Users/cbrisl/bin/git-repos/unite-train/work/35/1a72a2b0f2ec1daa4bdf505ea14871/taxonomy.qza, /Users/cbrisl/bin/git-repos/unite-train/work/35/1a72a2b0f2ec1daa4bdf505ea14871/taxonomy-no-SH.qza, /Users/cbrisl/bin/git-repos/unite-train/work/35/1a72a2b0f2ec1daa4bdf505ea14871/classifier.qza]
    // [2025-02-19, fungi, 99, false, /Users/cbrisl/bin/git-repos/unite-train/work/74/4631e2350e2a89c780987ddc6b7477/sequences.qza, /Users/cbrisl/bin/git-repos/unite-train/work/74/4631e2350e2a89c780987ddc6b7477/taxonomy.qza, /Users/cbrisl/bin/git-repos/unite-train/work/74/4631e2350e2a89c780987ddc6b7477/taxonomy-no-SH.qza, /Users/cbrisl/bin/git-repos/unite-train/work/74/4631e2350e2a89c780987ddc6b7477/classifier.qza]
    // [2025-02-19, fungi, 99, true, /Users/cbrisl/bin/git-repos/unite-train/work/9b/b38d151b8cb890909171711e9a66d8/sequences.qza, /Users/cbrisl/bin/git-repos/unite-train/work/9b/b38d151b8cb890909171711e9a66d8/taxonomy.qza, /Users/cbrisl/bin/git-repos/unite-train/work/9b/b38d151b8cb890909171711e9a66d8/taxonomy-no-SH.qza, /Users/cbrisl/bin/git-repos/unite-train/work/9b/b38d151b8cb890909171711e9a66d8/classifier.qza]
    // [2025-02-19, fungi, 97, false, /Users/cbrisl/bin/git-repos/unite-train/work/4e/2073e5dcf6c6e444fcdd2d9efb325b/sequences.qza, /Users/cbrisl/bin/git-repos/unite-train/work/4e/2073e5dcf6c6e444fcdd2d9efb325b/taxonomy.qza, /Users/cbrisl/bin/git-repos/unite-train/work/4e/2073e5dcf6c6e444fcdd2d9efb325b/taxonomy-no-SH.qza, /Users/cbrisl/bin/git-repos/unite-train/work/4e/2073e5dcf6c6e444fcdd2d9efb325b/classifier.qza]

    // Run the original sequences through the new classifiers

    ch_reclassification = RE_CLASSIFY_SKLEARN(ch_classifiers)
    ch_reclassification.view()

    ch_evaluation = EVALUATE_CLASSIFICATIONS(ch_reclassification)
    ch_evaluation.view()
}


// --- Processes ---
process GET_UNITE_DATA {
    label 'qiime2'

    input:
    tuple val(version), val(taxon_group), val(cluster_id), val(singletons)

    output:
    tuple val(version), val(taxon_group), val(cluster_id), val(singletons), path("sequences.qza"), path("taxonomy.qza"), emit: unite_files

    script:
    def singleton_flag = singletons ? '' : '--p-no-singletons'
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
    tuple val(version), val(taxon_group), val(cluster_id), val(singletons), path(sequences), path(taxonomy)

    output:
    tuple val(version), val(taxon_group), val(cluster_id), val(singletons), path(sequences), path(taxonomy), path("taxonomy-no-SH.qza"), emit: edit_taxonomy

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

process FIT_CLASSIFIER_NB {
    label 'qiime2'
    publishDir "${params.outdir}/classifier", mode: 'copy', saveAs: { filename ->
        if (filename == "classifier.qza") {
            // Previous name: unite_ver10_99_s_all_19.02.2025-Q2-2024.10.qza
            def s_str = singletons ? "_s" : ""
            return "unite_ver${version}_${cluster_id}${s_str}_${taxon_group}-Q2-2026.1.qza"
        }
        // don't publish other files
        return null
    }
    cpus 8

    input:
    tuple val(version), val(taxon_group), val(cluster_id), val(singletons), path(sequences), path(taxonomy), path(taxonomy_edit)

    output:
    tuple val(version), val(taxon_group), val(cluster_id), val(singletons), path(sequences), path(taxonomy), path(taxonomy_edit), path("classifier.qza"), emit: classifier

    script:
    """
    qiime feature-classifier fit-classifier-naive-bayes \\
        --p-classify--chunk-size 2000 \\
        --i-reference-reads ${sequences} \\
        --i-reference-taxonomy ${taxonomy_edit} \\
        --o-classifier classifier.qza
    """
}

// wrap `qiime feature-classifier classify-sklearn`
process RE_CLASSIFY_SKLEARN {
    label 'qiime2'
    cpus 4

    publishDir "${params.outdir}/evaluation", mode: 'copy', saveAs: { filename ->
        if (filename == "reclassification.qza") {
            def s_str = singletons ? "_s" : ""
            return "reclass_ver${version}_${cluster_id}${s_str}_${taxon_group}.qza"
        }
        return null
    }

    input:
    tuple val(version), val(taxon_group), val(cluster_id), val(singletons), path(sequences), path(taxonomy), path(taxonomy_edit), path(classifier)

    output:
    tuple val(version), val(taxon_group), val(cluster_id), val(singletons), path(sequences), path(taxonomy), path(taxonomy_edit), path(classifier), path("reclassification.qza"), emit: reclassification

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

// process EVALUATE_FIT_CLASSIFIER {
//     publishDir "${params.outdir}/evaluation", mode: 'copy'
//
//    label:
//    'qiime2'

//     input:
//     tuple path(classifier), path(sequences), path(taxonomy)

//     output:
//     tuple path("predicted-taxonomy.qza", emit: predicted_tax), path("classifier-evaluation.qzv", emit: evaluation)

//     script:
//     """
//     qiime rescript evaluate-fit-classifier \\
//         --i-sequences ${sequences} \\
//         --i-taxonomy ${taxonomy} \\
//         --i-classifier ${classifier} \\
//         --p-n-jobs ${task.cpus} \\
//         --o-evaluation classifier-evaluation.qzv \\
//         --o-observed-taxonomy predicted-taxonomy.qza
//     """
// }

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
    tuple val(version), val(taxon_group), val(cluster_id), val(singletons), path(sequences), path(tax_raw), path(tax_edit), path(classifier), path(tax_pred)

    output:
    tuple val(version), val(taxon_group), val(cluster_id), val(singletons), path("evaluation.qzv"), emit: evaluation

    script:
    """
    qiime rescript evaluate-classifications \\
        --i-expected-taxonomies ${tax_raw} ${tax_raw} \\
        --i-observed-taxonomies ${tax_edit} ${tax_pred} \\
        --p-labels 'no sh__' 'reclassified' \\
        --o-evaluation evaluation.qzv
    """
}
