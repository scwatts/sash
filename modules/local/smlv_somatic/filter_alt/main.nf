process FILTER_ALT {
  //conda (params.enable_conda ? "XXX" : null)
  //container 'XXX'

  input:
  val meta
  path vcf
  path tbi
  path refdata_main_contigs_bed

  output:
  path '*vcf.gz'     , emit: vcf
  path '*tbi'        , emit: tbi
  path 'versions.yml', emit: versions

  when:
  task.ext.when == null || task.ext.when

  script:
  def args = task.ext.args ?: ''

  """
  bolt smlv_somatic filter_alt \
    --smlv_vcf ${vcf} \
    --refdata_main_contigs_bed ${refdata_main_contigs_bed} \
    --output_fp filter_alt.vcf.gz

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
