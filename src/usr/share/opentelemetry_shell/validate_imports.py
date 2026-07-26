import ast
import glob

for path in glob.glob("/usr/share/opentelemetry_shell/*.py"):
    with open(path) as file:
        module = ast.parse(file.read(), path)
    module.body = sorted(
        (
            node
            for node in ast.walk(module)
            if isinstance(node, (ast.Import, ast.ImportFrom))
        ),
        key=lambda node: (node.lineno, node.col_offset),
    )
    exec(compile(module, path, "exec"), {})
