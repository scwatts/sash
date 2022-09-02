process SAGE {
  //conda (params.enable_conda ? "XXX" : null)
  //container 'XXX'

  // NOTE(SW): temp
  //memory = 8.GB
  //ext = ['jarPath': '/Users/stephen/repos/nextflow_pipelines/sash/misc/sage-1.0.jar']
  ext = ['jarPath': '/opt/conda/envs/hmftools/share/hmftools-sage-1.0-0/sage.jar']

  input:
  val meta
  path vcf
  path tbi
  path tumor_bam
  path normal_bam
  val refdata_genome_name
  path refdata_genome_dir
  path refdata_hotspots_vcf
  path refdata_coding_regions

  output:
  path '*vcf.gz'     , emit: vcf
  path '*tbi'        , emit: tbi
  path 'versions.yml', emit: versions

  when:
  task.ext.when == null || task.ext.when

  script:
  def args = task.ext.args ?: ''

  """
  bolt smlv_somatic sage/sage \
    --tumor_name ${meta.tumor_name} \
    --normal_name ${meta.normal_name} \
    --smlv_vcf ${vcf} \
    --tumor_bam ${tumor_bam} \
    --normal_bam ${normal_bam} \
    --refdata_genome ${refdata_genome_dir}/${refdata_genome_name} \
    --refdata_hotspots_vcf ${refdata_hotspots_vcf} \
    --refdata_coding_regions ${refdata_coding_regions} \
    --jar_path ${task.ext.jarPath} \
    --memory ${task.memory.giga} \
    --output_fp sage.vcf.gz

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
