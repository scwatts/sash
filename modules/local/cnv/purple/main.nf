process PURPLE {
  //conda (params.enable_conda ? "XXX" : null)
  //container 'XXX'

  // NOTE(SW): temp
  //memory = 8.GB
  //cpus = 4
  //ext = ['jarPath': '/Users/stephen/repos/nextflow_pipelines/sash/misc/purple-2.51.jar']
  ext = ['jarPath': '/opt/conda/envs/hmftools/share/hmftools-purple-2.51-1/purple.jar']

  input:
  val meta
  path sv_vcf
  path smlv_somatic_vcf
  path amber_dir
  path cobalt_dir
  val refdata_genome_name
  path refdata_genome_dir
  path refdata_gc_profile

  output:
  path 'purple/'                 , emit: purple_dir
  path 'purple/*sv.vcf.gz'       , emit: sv_vcf
  path 'purple/*.cnv.somatic.tsv', emit: cnv_tsv
  path 'versions.yml'            , emit: versions

  when:
  task.ext.when == null || task.ext.when

  script:
  def args = task.ext.args ?: ''

  """
  bolt cnv purple \
    --subject ${meta.id} \
    --normal_name ${meta.normal_name} \
    --amber_dir ${amber_dir} \
    --cobalt_dir ${cobalt_dir} \
    --sv_vcf ${sv_vcf} \
    --smlv_somatic_vcf ${smlv_somatic_vcf} \
    --refdata_gc_profile ${refdata_gc_profile} \
    --refdata_genome ${refdata_genome_dir}/${refdata_genome_name} \
    --jar_path ${task.ext.jarPath} \
    --memory ${task.memory.giga} \
    --threads ${task.cpus} \
    --output_dir purple/

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
