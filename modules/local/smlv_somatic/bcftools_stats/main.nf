process BCFTOOLS_STATS {
  //conda (params.enable_conda ? "XXX" : null)
  //container 'XXX'

  input:
  val meta
  path vcf

  output:
  path '*.txt'       , emit: stats
  path '*.tsv.gz'    , emit: qual_tsv
  path '*.tsv.gz.tbi', emit: qual_inde
  path 'versions.yml', emit: versions

  when:
  task.ext.when == null || task.ext.when

  script:
  def args = task.ext.args ?: ''

  """
  bolt smlv_somatic bcftools_stats \
    --tumor_name ${meta.tumor_name} \
    --smlv_vcf ${vcf} \
    --output_stats bcftools_stats.txt \
    --output_quality quality.tsv.gz

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
