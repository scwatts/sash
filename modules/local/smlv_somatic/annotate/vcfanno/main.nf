process VCFANNO {
  //conda (params.enable_conda ? "XXX" : null)
  //container 'XXX'

  input:
  path vcf
  path toml
  path prepared_hotspots_vcf
  path refdata_ga4gh_dir
  path refdata_lcr
  path refdata_segdup
  path refdata_gnomad_vcf
  path refdata_giab_high_conf
  path refdata_encode
  path prepared_hotspots_tbi
  path refdata_lcr_tbi
  path refdata_segdup_tbi
  path refdata_gnomad_tbi
  path refdata_giab_high_conf_tbi
  path refdata_encode_tbi

  output:
  path '*.vcf.gz'    , emit: vcf
  path '*.tbi'       , emit: tbi
  path 'versions.yml', emit: versions

  when:
  task.ext.when == null || task.ext.when

  script:
  def args = task.ext.args ?: ''

  """
  bolt smlv_somatic annotate/vcfanno \
    --smlv_vcf ${vcf} \
    --toml ${toml} \
    --output_fp vcfanno.vcf.gz

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
