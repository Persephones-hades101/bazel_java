# custom_rules/xsd_jaxb.bzl

def _xsd_jaxb_impl(ctx):
    # Output directory for generated Java files
    output_dir = ctx.actions.declare_directory(ctx.attr.name + "_generated_sources")
    
    # Declare the source jar that will contain the generated sources
    source_jar = ctx.outputs.source_jar
    
    # Collect all XSD files
    xsd_files = ctx.files.srcs
    
    # Construct args for xjc
    args = ctx.actions.args()
    
    # Add common options
    args.add("-d", output_dir.path)  # Output directory
    
    if ctx.attr.package:
        args.add("-p", ctx.attr.package)  # Target package for generated classes
    
    # Add XSD source files
    for xsd in xsd_files:
        args.add(xsd.path)
    
    # Add any custom arguments provided
    for arg in ctx.attr.xjc_args:
        args.add(arg)
    
    # Get Java runtime for executing the XJC tool
    java_runtime = ctx.attr._jdk[java_common.JavaRuntimeInfo]
    
    # Get Java toolchain
    java_toolchain = ctx.attr._java_toolchain[java_common.JavaToolchainInfo]
    
    # Construct the classpath for running XJC
    classpath_jars = []
    for dep in ctx.attr._jaxb_deps:
        classpath_jars.extend(dep[JavaInfo].compile_jars.to_list())
    
    # Create a classpath file to avoid command line length limitations
    classpath_file = ctx.actions.declare_file(ctx.attr.name + "_classpath")
    ctx.actions.write(
        output = classpath_file,
        content = ":".join([jar.path for jar in classpath_jars]),
    )
    
    # Run the XJC tool
    ctx.actions.run(
        outputs = [output_dir],
        inputs = xsd_files + classpath_jars,
        executable = java_runtime.java_executable_exec_path,
        tools = [classpath_file],
        arguments = [
            "-classpath", "@" + classpath_file.path,
            "com.sun.tools.xjc.XJCFacade",
        ] + [args],
        progress_message = "Generating Java sources from XSD files %s" % ctx.attr.name,
    )
    
    # Pack the generated sources into a source JAR
    java_common.pack_sources(
        ctx.actions,
        output_source_jar = source_jar,
        sources = [output_dir],
        java_toolchain = java_toolchain,
    )
    
    # Create a simple Java library for the generated sources
    srcjar_java_info = JavaInfo(
        output_jar = ctx.outputs.jar,
        source_jar = source_jar,
        compile_jar = ctx.outputs.jar,
        deps = [dep[JavaInfo] for dep in ctx.attr.deps],
    )
    
    # Return the information about our library
    return [
        DefaultInfo(
            files = depset([ctx.outputs.jar, source_jar]),
        ),
        srcjar_java_info,
    ]

# Rule definition
xsd_jaxb = rule(
    implementation = _xsd_jaxb_impl,
    attrs = {
        "srcs": attr.label_list(
            allow_files = [".xsd"],
            mandatory = True,
            doc = "XSD schema files to process",
        ),
        "deps": attr.label_list(
            providers = [JavaInfo],
            doc = "Java dependencies for the generated code",
        ),
        "package": attr.string(
            doc = "Java package for the generated classes",
        ),
        "xjc_args": attr.string_list(
            doc = "Additional arguments to pass to the XJC tool",
            default = [],
        ),
        "_jaxb_deps": attr.label_list(
            default = [
                "@maven//:javax_xml_bind_jaxb_api",
                "@maven//:org_glassfish_jaxb_jaxb_runtime",
                "@maven//:org_glassfish_jaxb_jaxb_xjc",
                "@maven//:com_sun_xml_bind_jaxb_impl",
                "@maven//:com_sun_activation_javax_activation",
                "@maven//:javax_annotation_javax_annotation_api",
            ],
            doc = "JAXB dependencies from Maven",
        ),
        "_jdk": attr.label(
            default = Label("@bazel_tools//tools/jdk:current_java_runtime"),
            providers = [java_common.JavaRuntimeInfo],
        ),
        "_java_toolchain": attr.label(
            default = Label("@bazel_tools//tools/jdk:current_java_toolchain"),
            providers = [java_common.JavaToolchainInfo],
        ),
    },
    outputs = {
        "jar": "%{name}.jar",
        "source_jar": "%{name}-src.jar",
    },
    toolchains = ["@bazel_tools//tools/jdk:toolchain_type"],
    fragments = ["java"],
)