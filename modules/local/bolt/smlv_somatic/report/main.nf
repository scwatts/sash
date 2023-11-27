process BOLT_SMLV_SOMATIC_REPORT {
    tag "${meta.id}"
    label 'process_low'

    container 'ghcr.io/scwatts/bolt:0.2.8-pcgr'

    input:
    tuple val(meta), path(smlv_vcf), path(smlv_filters_vcf), path(smlv_dragen_vcf), path(purple_purity)
    path pcgr_data_dir
    path somatic_driver_panel_regions_coding
    path giab_regions
    path genome_fasta
    path genome_fai

    output:
    tuple val(meta), path('output/af_tumor.txt')                 , emit: af_global
    tuple val(meta), path('output/af_tumor_keygenes.txt')        , emit: af_keygenes
    tuple val(meta), path("output/*.bcftools_stats.txt")         , emit: bcftools_stats
    tuple val(meta), path("output/*.variant_counts_type.yaml")   , emit: counts_type
    tuple val(meta), path("output/*.variant_counts_process.json"), emit: counts_process
    path 'output/pcgr/'                                          , emit: pcgr_dir
    path "output/*.pcgr_acmg.grch38.html"                        , emit: pcgr_report
    path 'versions.yml'                                          , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''

    """
    bolt smlv_somatic report \\
        --tumor_name ${meta.tumor_id} \\
        --normal_name ${meta.normal_id} \\
        \\
        --vcf_fp ${smlv_vcf} \\
        --vcf_filters_fp ${smlv_filters_vcf} \\
        --vcf_dragen_fp ${smlv_dragen_vcf} \\
        \\
        --pcgr_conda pcgr \\
        --pcgrr_conda pcgrr \\
        --pcgr_data_dir ${pcgr_data_dir} \\
        --purple_purity_fp ${purple_purity} \\
        \\
        --cancer_genes_fp ${somatic_driver_panel_regions_coding} \\
        --giab_regions_fp ${giab_regions} \\
        --genome_fp ${genome_fasta} \\
        \\
        --threads ${task.cpus} \\
        --output_dir output/

    mv output/pcgr/${meta.tumor_id}.pcgr_acmg.grch38.html output/

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bolt: \$(bolt --version | sed 's/^.*version //')
    END_VERSIONS
    """

    stub:
    """
    mkdir -p pcgr_output/
    touch af_tumor.txt
    touch af_tumor_keygenes.txt
    touch ${meta.tumor_id}.somatic.variant_counts.yaml
    touch ${meta.tumor_id}.somatic.bcftools_stats.txt
    echo -e '${task.process}:\\n  stub: noversions\\n' > versions.yml
    """
}

