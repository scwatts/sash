process AMBER {
  //conda (params.enable_conda ? "XXX" : null)
  //container 'XXX'

  // NOTE(SW): temp
  //memory = 8.GB
  //cpus = 4
  //ext = ['jarPath': '/Users/stephen/repos/nextflow_pipelines/sash/misc/amber-3.5.jar']
  ext = ['jarPath': '/opt/conda/envs/hmftools/share/hmftools-amber-3.5-1/amber.jar']

  input:
  val meta
  path tumor_bam
  path normal_bam
  val refdata_genome_name
  path refdata_genome_dir
  path refdata_germline_het_pon

  output:
  path 'amber/'      , emit: amber_dir
  path 'versions.yml', emit: versions

  when:
  task.ext.when == null || task.ext.when

  script:
  def args = task.ext.args ?: ''

  """
  bolt cnv amber \
    --subject ${meta.id} \
    --normal_name ${meta.normal_name} \
    --tumor_bam ${tumor_bam} \
    --normal_bam ${normal_bam} \
    --refdata_germline_het_pon ${refdata_germline_het_pon} \
    --refdata_genome ${refdata_genome_dir}/${refdata_genome_name} \
    --jar_path ${task.ext.jarPath} \
    --memory ${task.memory.giga} \
    --threads ${task.cpus} \
    --output_dir amber/

  cat <<-END_VERSIONS > versions.yml
    "${task.process}":
      bolt: \$(bolt --version | cut -f3 -d' ')
  END_VERSIONS
  """

  stub:
  """
  echo -e '${task.process}:\\n  stub: noversions\\n' > versions.yml
  """
}
