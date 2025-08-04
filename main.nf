#!/usr/bin/env nextflow
nextflow.enable.dsl=2

// --- Parameters ---
// These are now at the top, processed first.
params.version = "2025-02-19"
params.taxon_group = "fungi"
params.cluster_id = "99"
params.singletons = false
params.outdir = "./results"

// --- Workflow ---
workflow {
    log.info """
        Q2 RESCRIPt UNITE Database Workflow
        ===================================
        version     : ${params.version}
        taxon_group : ${params.taxon_group}
        cluster_id  : ${params.cluster_id}
        singletons  : ${params.singletons}
        outdir      : ${params.outdir}
        """

    // 1. Create a channel that emits a single tuple containing the parameters
    ch_unite_params = Channel.of( [
        params.version,
        params.taxon_group,
        params.cluster_id,
        params.singletons
    ] )

    // 2. Call the process with the single channel
    ch_unite_raw = GET_UNITE_DATA(ch_unite_params)

    // 3. Edit taxonomy to remove SH identifiers
    ch_tax_edited = EDIT_TAXONOMY(ch_unite_raw)

    ch_original_seqs = ch_unite_raw.map { seq, tax -> seq }

    // 4. Train the classifier
    ch_classifier = TRAIN_CLASSIFIER(
        ch_original_seqs.combine(ch_tax_edited)
    )

    // // 5. Evaluate the classifier
    // ch_eval_results = EVALUATE_CLASSIFIER(
    //     ch_classifier.combine(ch_original_seqs).combine(ch_tax_edited)
    // )

    // // 6. Evaluate the taxonomy predictions against the reference
    // EVALUATE_TAXONOMY(
    //     ch_tax_edited.combine(ch_eval_results.predicted_tax)
    // )
}


// --- Processes ---
process GET_UNITE_DATA {
    // publishDir "${params.outdir}/unite_db_raw", mode: 'copy'

    input:
    tuple val(version), val(taxon_group), val(cluster_id), val(singletons)

    output:
    tuple path("sequences.qza"), path("taxonomy.qza"), emit: unite_files

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
    publishDir "${params.outdir}/unite_db_curated", mode: 'copy'

    input:
    tuple path(sequences), path(taxonomy) // `sequences` is unused but simplifies channel combining

    output:
    path "taxonomy-no-SH.qza", emit: taxonomy

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

process TRAIN_CLASSIFIER {
    publishDir "${params.outdir}/classifier", mode: 'copy'

    input:
    tuple path(sequences), path(taxonomy)

    output:
    path "classifier.qza", emit: classifier

    script:
    """
    qiime feature-classifier fit-classifier-naive-bayes \\
        --p-classify--chunk-size 10000 \\
        --i-reference-reads ${sequences} \\
        --i-reference-taxonomy ${taxonomy} \\
        --o-classifier classifier.qza
    """
}

// process EVALUATE_CLASSIFIER {
//     publishDir "${params.outdir}/evaluation", mode: 'copy'

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

// process EVALUATE_TAXONOMY {
//     publishDir "${params.outdir}/evaluation", mode: 'copy'

//     input:
//     tuple path(ref_tax), path(pred_tax)

//     output:
//     path "both-taxonomy-evaluation.qzv"

//     script:
//     """
//     qiime rescript evaluate-taxonomy \\
//         --i-taxonomies ${ref_tax} ${pred_tax} \\
//         --p-labels ref-taxonomy predicted-taxonomy \\
//         --o-taxonomy-stats both-taxonomy-evaluation.qzv
//     """
// }
