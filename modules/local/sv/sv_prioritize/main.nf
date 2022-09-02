process SV_PRIORITIZE {
  //conda (params.enable_conda ? "XXX" : null)
  //container 'XXX'

  input:
  val meta
  path vcf
  path refdata_known_fusion_pairs
  path refdata_known_fusion_heads
  path refdata_known_fusion_tails
  path refdata_fusioncatcher_pairs
  path refdata_key_genes_txt
  path refdata_key_tsgenes_txt
  path bed_annotations_appris

  output:
  path '*.vcf.gz'    , emit: vcf
  path '*.tbi'       , emit: tbi
  path 'versions.yml', emit: versions

  when:
  task.ext.when == null || task.ext.when

  script:
  def args = task.ext.args ?: ''

  """
  bolt sv sv_prioritize \
    --sv_vcf ${vcf} \
    --refdata_known_fusion_pairs ${refdata_known_fusion_pairs} \
    --refdata_known_fusion_heads ${refdata_known_fusion_heads} \
    --refdata_known_fusion_tails ${refdata_known_fusion_tails} \
    --refdata_fusioncatcher_pairs ${refdata_fusioncatcher_pairs} \
    --refdata_key_genes ${refdata_key_genes_txt} \
    --refdata_key_tsgenes ${refdata_key_tsgenes_txt} \
    --bed_annotations_appris ${bed_annotations_appris} \
    --output_fp prioritized.vcf.gz

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
