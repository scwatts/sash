process SIGRAP_HRDETECT {
    tag "${meta.id}"
    label 'process_low'

    container 'ghcr.io/umccr/sigrap:0.2.0'

    input:
    tuple val(meta), path(smlv_somatic_vcf), path(smlv_somatic_bcftools_stats), path(smlv_somatic_counts_process), path(sv_somatic_tsv), path(sv_somatic_vcf), path(cnv_somatic_tsv), path(af_global), path(af_keygenes), path(purple_baf_plot), path(purple_dir), path(virusbreakend_dir), path(dragen_hrd)

    output:
    path 'output/hrdetect.json.gz'                            , emit: hrdetect_json
    path 'versions.yml'                                       , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''

    """
    sigrap hrdetect \\
        --sample ${meta.subject_id} \\
        --snv ${smlv_somatic_vcf} \\
        --sv ${sv_somatic_vcf} \\
        --cnv ${cnv_somatic_tsv} \\
        --out  output/

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        sigrap: \$(sigrap --version | sed 's/^.*version //')
    END_VERSIONS
    """

    stub:
    """
    mkdir -p output/
    touch output/hrdetect.json.gz
    echo -e '${task.process}:\\n  stub: noversions\\n' > versions.yml
    """
}
