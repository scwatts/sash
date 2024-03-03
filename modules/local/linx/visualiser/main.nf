process LINX_VISUALISER {
    tag "${meta.id}"
    label 'process_medium'

    container 'quay.io/biocontainers/hmftools-linx:1.25--hdfd78af_0'

    input:
    tuple val(meta), path(linx_annotation_dir)
    val genome_ver
    path ensembl_data_resources

    output:
    tuple val(meta), path('plots/'), emit: plots
    path 'versions.yml'            , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''

    """
    mkdir -p plots/

    # NOTE(SW): LINX v1.24.1 require trailing slashes for the -plot_out and -data_out arguments since no filesystem
    # separator is used when constructing fusion plot output filepaths.

    # https://github.com/hartwigmedical/hmftools/blob/linx-v1.24.1/linx/src/main/java/com/hartwig/hmftools/linx/visualiser/circos/ChromosomeRangeExecution.java#L22-L29
    # https://github.com/hartwigmedical/hmftools/blob/linx-v1.24.1/linx/src/main/java/com/hartwig/hmftools/linx/visualiser/circos/FusionExecution.java#L18-L23

    linx \\
        -Xmx${Math.round(task.memory.bytes * 0.95)} \\
        com.hartwig.hmftools.linx.visualiser.SvVisualiser \\
        ${args} \\
        -sample ${meta.sample_id} \\
        -vis_file_dir ${linx_annotation_dir} \\
        -ref_genome_version ${genome_ver} \\
        -ensembl_data_dir ${ensembl_data_resources} \\
        -circos \$(which circos) \\
        -threads ${task.cpus} \\
        -plot_out plots/ \\
        -data_out data/

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        linx: \$(linx -version | sed 's/^.* //')
    END_VERSIONS
    """

    stub:
    """
    mkdir -p plots/
    touch plots/placeholder
    echo -e '${task.process}:\n  stub: noversions\n' > versions.yml
    """
}
