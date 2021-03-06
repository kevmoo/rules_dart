# Copyright 2016 The Bazel Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""Dart rules shared across deployment platforms."""

load(
    ":internal.bzl",
    "assert_third_party_licenses",
    "has_dart_sources",
    "make_dart_context",
    "api_summary_extension",
)
load(":analyze.bzl", "summary_action")
load(":ddc.bzl", "ddc_action")

def _dart_library_impl(ctx):
  """Implements the dart_library() rule."""
  assert_third_party_licenses(ctx)

  ddc_output = ctx.outputs.ddc_output
  source_map_output = ctx.outputs.ddc_sourcemap
  strong_summary = ctx.outputs.strong_summary
  _has_dart_sources = has_dart_sources(ctx.files.srcs)

  dart_ctx = make_dart_context(ctx.label,
                               srcs=ctx.files.srcs,
                               data=ctx.files.data,
                               deps=ctx.attr.deps,
                               pub_pkg_name=ctx.attr.pub_pkg_name,
                               strong_summary=strong_summary,)

  if not _has_dart_sources:
    ctx.file_action(
        output=strong_summary,
        content=("// empty summary, package %s has no dart sources" %
                 ctx.label.name))
  else:
    summary_action(ctx, dart_ctx)

  if not _has_dart_sources:
    ctx.file_action(
        output=ddc_output,
        content=("// intentionally empty: package %s has no dart sources" %
                 ctx.label.name))
    ctx.file_action(
        output=source_map_output,
        content=("// intentionally empty: package %s has no dart sources" %
                 ctx.label.name))
  else:
    ddc_action(ctx, dart_ctx, ddc_output, source_map_output)

  return struct(
      dart=dart_ctx,
      ddc=struct(
        output=ddc_output,
        sourcemap=source_map_output,
      ),
  )

def _dart_library_outputs():
  """Returns the outputs of a Dart library rule.

  Dart library targets emit the following outputs:

  * name.api.ds: the strong-mode summary from dart analyzer (API only), if specified.
  * name.js:     the js generated by DDC
  * name.js.map: the source map generated by DDC

  Returns:
    a dict of types of outputs to their respective file suffixes
  """
  outs = {
    "ddc_output": "%{name}.js",
    "ddc_sourcemap": "%{name}.js.map",
    "strong_summary": "%{name}." + api_summary_extension,
  }

  return outs

_dart_library_attrs = {
    "srcs": attr.label_list(
        allow_files = True,
        mandatory = True,
    ),
    "data": attr.label_list(
        allow_files = True,
        cfg = "data",
    ),
    "pub_pkg_name": attr.string(default = ""),
    "deps": attr.label_list(providers = ["dart"]),
    "force_ddc_compile": attr.bool(default = False),
    "license_files": attr.label_list(allow_files = True),
    "web_exclude_srcs": attr.label_list(allow_files = True),
    "_analyzer": attr.label(
        default = Label("//dart/build_rules/ext:dart_analyzer"),
        executable = True,
        cfg = "host",
    ),
    "_dev_compiler": attr.label(
        default = Label("//dart/build_rules/ext:dev_compiler"),
        executable = True,
        cfg = "host",
    ),
}

dart_library = rule(
    attrs = _dart_library_attrs,
    outputs = _dart_library_outputs,
    implementation = _dart_library_impl,
)
