load("//dart/build_rules:core.bzl", "dart_library")

package(default_visibility = ["//visibility:public"])

dart_library(
    name = "shelf",
    srcs = [
        "@vendor_shelf//:shelf"
    ],
    license_files = ["@vendor_shelf//:LICENSE_FILES"],
    pub_pkg_name = "shelf",
    deps = [
        "//vendor/async",
        "//vendor/http_parser",
        "//vendor/path",
        "//vendor/stack_trace",
        "//vendor/stream_channel",
    ],
)
