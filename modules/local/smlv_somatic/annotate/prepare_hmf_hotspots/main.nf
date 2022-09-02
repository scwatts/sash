process PREPARE_HMF_HOTSPOTS {
  //conda (params.enable_conda ? "XXX" : null)
  //container 'XXX'

  input:
  path refdata_hotspots_vcf

  output:
  path '*vcf.gz'     , emit: vcf
  path '*tbi'        , emit: tbi
  path 'versions.yml', emit: versions


  when:
  task.ext.when == null || task.ext.when

  script:
  def args = task.ext.args ?: ''

  """
  bolt smlv_somatic annotate/prepare_hmf_hotspots \
    --refdata_hotspots_vcf ${refdata_hotspots_vcf} \
    --output_fp hotspots.vcf.gz

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
