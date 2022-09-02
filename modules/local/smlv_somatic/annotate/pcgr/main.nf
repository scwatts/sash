process PCGR {
  //conda (params.enable_conda ? "XXX" : null)
  //container 'XXX'

  input:
  val meta
  path vcf
  path tbi
  path refdata_pcgr_dir
  path refdata_pcgr_toml
  path refdata_cpsr_toml

  output:
  path 'pcgr/*.pcgr_ready.vep.vcf.gz'    , emit: vcf
  path 'pcgr/*.pcgr_ready.vep.vcf.gz.tbi', emit: tbi
  path 'pcgr/*.tsv'                      , emit: tsv
  path 'versions.yml'                    , emit: versions

  when:
  task.ext.when == null || task.ext.when

  script:
  def args = task.ext.args ?: ''

  """
  bolt smlv_somatic annotate/pcgr \
    --sample_name ${meta.id} \
    --smlv_vcf ${vcf} \
    --refdata_pcgr_dir ${refdata_pcgr_dir} \
    --refdata_pcgr_toml ${refdata_pcgr_toml} \
    --refdata_cpsr_toml ${refdata_cpsr_toml} \
    --output_dir pcgr/

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
