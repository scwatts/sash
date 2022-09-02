process ANNOTATE_UMCCR_PON {
  //conda (params.enable_conda ? "XXX" : null)
  //container 'XXX'

  input:
  val meta
  path vcf
  path tbi
  path refdata_umccr_pon_dir
  path refdata_umccr_pon_snps_toml
  path refdata_umccr_pon_indels_toml

  output:
  path '*.vcf.gz'    , emit: vcf
  path '*.tbi'       , emit: tbi
  path 'versions.yml', emit: versions

  when:
  task.ext.when == null || task.ext.when

  script:
  def args = task.ext.args ?: ''

  """
  bolt smlv_somatic annotate/annotate_umccr_pon \
    --smlv_vcf ${vcf} \
    --refdata_umccr_pon_dir ${refdata_umccr_pon_dir} \
    --refdata_snps_toml ${refdata_umccr_pon_snps_toml} \
    --refdata_indels_toml ${refdata_umccr_pon_indels_toml} \
    --output_fp annotated_with_umccr_pon.vcf.gz

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
