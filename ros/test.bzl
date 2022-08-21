""" Implements functionality for defining ROS tests using rostest.
"""

load("//third_party:expand_template.bzl", "expand_template")
load("@rules_python//python:defs.bzl", "py_test")

def ros_test(name, nodes, launch_file, launch_args = None, **kwargs):
    """ Defines a ROS test.

    Args:
        name: A unique target name.
        nodes: A list of ROS nodes used by the test.
        launch_file: A rostest-compatible launch file.
        launch_args: A list of rostest arguments used by the test.
        **kwargs: https://bazel.build/reference/be/common-definitions#common-attributes-tests
    """
    launch_file_path = "'$(location {})'".format(launch_file)
    launch_args = launch_args or []
    substitutions = {
        "{launch_file}": launch_file_path,
        "{launch_args}": ", ".join(launch_args),
    }

    launch_script = "{}_launch.py".format(name)
    expand_template(
        name = "{}_launch_gen".format(name),
        template = "@com_github_mvukov_rules_ros//ros:test.py.tpl",
        substitutions = substitutions,
        out = launch_script,
        data = [launch_file],
    )

    py_test(
        name = name,
        srcs = [launch_script],
        data = nodes + [launch_file],
        main = launch_script,
        deps = ["@com_github_mvukov_rules_ros//third_party/legacy_rostest"],
        **kwargs
    )
