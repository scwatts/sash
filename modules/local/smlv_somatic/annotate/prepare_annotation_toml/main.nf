process PREPARE_ANNOTATION_TOML {
  //conda (params.enable_conda ? "XXX" : null)
  //container 'XXX'

  input:
  path prepared_hotspots_vcf
  path refdata_ga4gh_dir
  path refdata_lcr
  path refdata_segdup
  path refdata_gnomad_vcf
  path refdata_giab_high_conf
  path refdata_encode

  output:
  path '*toml'       , emit: toml
  path 'versions.yml', emit: versions

  when:
  task.ext.when == null || task.ext.when

  script:
  def args = task.ext.args ?: ''

  """
  bolt smlv_somatic annotate/prepare_annotation_toml \
    --prepared_hotspots_vcf ${prepared_hotspots_vcf} \
    --refdata_ga4gh_dir ${refdata_ga4gh_dir} \
    --refdata_lcr ${refdata_lcr} \
    --refdata_segdup ${refdata_segdup} \
    --refdata_gnomad_vcf ${refdata_gnomad_vcf} \
    --refdata_giab_high_conf ${refdata_giab_high_conf} \
    --refdata_encode ${refdata_encode} \
    --output_fp annotation.toml

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
