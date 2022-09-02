process COBALT {
  //conda (params.enable_conda ? "XXX" : null)
  //container 'XXX'

  // NOTE(SW): temp
  //memory = 8.GB
  //cpus = 4
  //ext = ['jarPath': '/Users/stephen/repos/nextflow_pipelines/sash/misc/cobalt-1.11.jar']
  ext = ['jarPath': '/opt/conda/envs/hmftools/share/hmftools-cobalt-1.11-1/cobalt.jar']

  input:
  val meta
  path tumor_bam
  path normal_bam
  val refdata_genome_name
  path refdata_genome_dir
  path refdata_gc_profile

  output:
  path 'cobalt/'     , emit: cobalt_dir
  path 'versions.yml', emit: versions

  when:
  task.ext.when == null || task.ext.when

  script:
  def args = task.ext.args ?: ''

  """
  bolt cnv cobalt \
    --subject ${meta.id} \
    --normal_name ${meta.normal_name} \
    --tumor_bam ${tumor_bam} \
    --normal_bam ${normal_bam} \
    --refdata_genome ${refdata_genome_dir}/${refdata_genome_name} \
    --refdata_gc_profile ${refdata_gc_profile} \
    --jar_path ${task.ext.jarPath} \
    --memory ${task.memory.giga} \
    --threads ${task.cpus} \
    --output_dir cobalt/

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
