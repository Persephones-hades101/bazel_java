# custom_rules/property_rules.bzl

def _properties_impl(ctx):
    # Create the output file
    output = ctx.actions.declare_file(ctx.attr.name + ".properties")
    
    # Prepare the content
    content_lines = []
    for key, value in ctx.attr.properties.items():
        content_lines.append(key + "=" + value)
    content = "\n".join(content_lines)
    
    # Write the content to the output file
    ctx.actions.write(
        output = output,
        content = content,
    )
    
    # Return the DefaultInfo provider to make the output file accessible
    return [DefaultInfo(files = depset([output]))]

# Define the rule with its attributes
properties_file = rule(
    implementation = _properties_impl,
    attrs = {
        "properties": attr.string_dict(
            mandatory = True,
            doc = "The key-value pairs to include in the properties file",
        ),
    },
)