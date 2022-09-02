process FILTER_ANNOTATIONS {
  //conda (params.enable_conda ? "XXX" : null)
  //container 'XXX'

  input:
  val meta
  path vcf

  output:
  output:
  path '*vcf.gz'     , emit: vcf
  path 'versions.yml', emit: versions

  when:
  task.ext.when == null || task.ext.when

  script:
  def args = task.ext.args ?: ''

  """
  bolt smlv_somatic filter_annotations \
    --tumor_name ${meta.tumor_name} \
    --normal_name ${meta.normal_name} \
    --smlv_vcf ${vcf} \
    --output_fp filters_set.vcf.gz

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
