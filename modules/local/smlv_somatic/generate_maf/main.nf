process GENERATE_MAF {
  //conda (params.enable_conda ? "XXX" : null)
  //container 'XXX'

  input:
  val meta
  path vcf
  val refdata_genome_name
  path refdata_genome_dir

  output:
  path '*.maf'       , emit: maf
  path 'versions.yml', emit: versions

  when:
  task.ext.when == null || task.ext.when

  script:
  def args = task.ext.args ?: ''

  """
  bolt smlv_somatic generate_maf \
    --tumor_name ${meta.tumor_name} \
    --normal_name ${meta.normal_name} \
    --smlv_vcf ${vcf} \
    --refdata_genome ${refdata_genome_dir}/${refdata_genome_name} \
    --output_fp output.maf

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
