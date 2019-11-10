# cython: c_string_type=unicode, c_string_encoding=utf8

from cpython.ref cimport PyObject 
from libc.stddef cimport wchar_t

cdef extern from "Python.h":
    PyObject* PyUnicode_FromWideChar(wchar_t *w, Py_ssize_t size)

from .gdnative_api_struct cimport (
    godot_pluginscript_language_data,
    godot_string,
    godot_bool,
    godot_array,
    godot_pool_string_array,
    godot_object,
    godot_variant,
    godot_error,
    godot_dictionary
)
from .gdapi cimport gdapi


cdef object godot_string_to_pyobj(const godot_string *p_gdstr):
    cdef const wchar_t * result = gdapi.godot_string_wide_str(p_gdstr)
    cdef PyObject * pystr = PyUnicode_FromWideChar(result, -1)
    return <object>pystr


cdef godot_string pyobj_to_godot_string(object pystr):
    cdef godot_string gdstr;
    gdapi.godot_string_new_with_wide_string(
        &gdstr, <wchar_t*><char*>pystr, len(pystr)
    )
    return gdstr


cdef object variant_to_pyobj(const godot_variant *p_gdvar):
    return None


cdef api godot_string pythonscript_get_template_source_code(
    godot_pluginscript_language_data *p_data,
    const godot_string *p_class_name,
    const godot_string *p_base_class_name
):
    # TODO: Cython consider wchat_t not portable, hence on linux we do
    # dirty cast between `wchar_t *` band `char *`. This is likely to
    # fail under Windows (where we should be able to use
    # `PyUnicode_AsWideChar` instead)
    cdef bytes base_class_name = <char*>gdapi.godot_string_wide_str(p_base_class_name)
    cdef bytes class_name
    if p_class_name == NULL:
        class_name = b"MyExportedCls"
    else:
        class_name = <char*>gdapi.godot_string_wide_str(p_class_name)
    cdef bytes src = b"""from godot import exposed, export
from godot.bindings import *
from godot.globals import *


@exposed
class {}({}):

    # member variables here, example:
    a = export(int)
    b = export(str, default='foo')

    def _ready(self):
        \"\"\"
        Called every time the node is added to the scene.
        Initialization here.
        \"\"\"
        pass
""".format(class_name, base_class_name)
    cdef godot_string ret
    gdapi.godot_string_new_with_wide_string(&ret, <wchar_t*><char*>src, len(src))
    return ret


cdef api godot_bool pythonscript_validate(
    godot_pluginscript_language_data *p_data,
    const godot_string *p_script,
    int *r_line_error,
    int *r_col_error,
    godot_string *r_test_error,
    const godot_string *p_path,
    godot_pool_string_array *r_functions
):
    pass


cdef api int pythonscript_find_function(
    godot_pluginscript_language_data *p_data,
    const godot_string *p_function,
    const godot_string *p_code
):
    return 0


cdef api godot_string pythonscript_make_function(
    godot_pluginscript_language_data *p_data,
    const godot_string *p_class,
    const godot_string *p_name,
    const godot_pool_string_array *p_args
):
#     args = PoolStringArray.build_from_gdobj(args, steal=True)
#     name = godot_string_to_pyobj(name)
#     src = ["def %s(" % name]
#     src.append(", ".join([arg.split(":", 1)[0] for arg in args]))
#     src.append("):\n    pass")
#     return "".join(src)
    cdef godot_string ret
    cdef bytes src = b"def dummy():\n    pass\n"
    gdapi.godot_string_new_with_wide_string(&ret, <wchar_t*><char*>src, len(src))
    return ret


cdef api godot_error pythonscript_complete_code(
    godot_pluginscript_language_data *p_data,
    const godot_string *p_code,
    const godot_string *p_base_path,
    godot_object *p_owner,
    godot_array *r_options,
    godot_bool *r_force,
    godot_string *r_call_hint
):
    return godot_error.GODOT_OK


cdef api void pythonscript_auto_indent_code(
    godot_pluginscript_language_data *p_data,
    godot_string *p_code,
    int p_from_line,
    int p_to_line
):
#     try:
#         import autopep8
#     except ImportError:
#         print(
#             "[Pythonscript] Auto indent requires module `autopep8`, "
#             "install it with `pip install autopep8`"
#         )
#     pycode = godot_string_to_pyobj(code).splitlines()
#     before = "\n".join(pycode[:from_line])
#     to_fix = "\n".join(pycode[from_line:to_line])
#     after = "\n".join(pycode[to_line:])
#     fixed = autopep8.fix_code(to_fix)
#     final_code = "\n".join((before, fixed, after))
#     # TODO: modify code instead of replace it when binding on godot_string
#     # operation is available
#     lib.godot_string_destroy(code)
#     lib.godot_string_new_unicode_data(code, final_code, len(final_code))
    pass


cdef api void pythonscript_add_global_constant(
    godot_pluginscript_language_data *p_data,
    const godot_string *p_variable,
    const godot_variant *p_value
):
    name = godot_string_to_pyobj(p_variable)
    value = variant_to_pyobj(p_value)
    # Update `godot.globals` module here
    import godot
    godot.globals.__dict__[name] = value


cdef api godot_string pythonscript_debug_get_error(
    godot_pluginscript_language_data *p_data
):
    cdef godot_string ret
    cdef bytes src = b"Nothing"
    gdapi.godot_string_new_with_wide_string(&ret, <wchar_t*><char*>src, len(src))
    return ret


cdef api int pythonscript_debug_get_stack_level_count(
    godot_pluginscript_language_data *p_data
):
    return 1


cdef api int pythonscript_debug_get_stack_level_line(
    godot_pluginscript_language_data *p_data,
    int p_level
):
    return 1


cdef api godot_string pythonscript_debug_get_stack_level_function(
    godot_pluginscript_language_data *p_data,
    int p_level
):
    cdef godot_string ret
    cdef bytes src = b"Nothing"
    gdapi.godot_string_new_with_wide_string(&ret, <wchar_t*><char*>src, len(src))
    return ret


cdef api godot_string pythonscript_debug_get_stack_level_source(
    godot_pluginscript_language_data *p_data,
    int p_level
):
    cdef godot_string ret
    cdef bytes src = b"Nothing"
    gdapi.godot_string_new_with_wide_string(&ret, <wchar_t*><char*>src, len(src))
    return ret


cdef api void pythonscript_debug_get_stack_level_locals(
    godot_pluginscript_language_data *p_data,
    int p_level,
    godot_pool_string_array *p_locals,
    godot_array *p_values,
    int p_max_subitems,
    int p_max_depth
):
    pass


cdef api void pythonscript_debug_get_stack_level_members(
    godot_pluginscript_language_data *p_data,
    int p_level,
    godot_pool_string_array *p_members,
    godot_array *p_values,
    int p_max_subitems,
    int p_max_depth
):
    pass


cdef api void pythonscript_debug_get_globals(
    godot_pluginscript_language_data *p_data,
    godot_pool_string_array *p_locals,
    godot_array *p_values,
    int p_max_subitems,
    int p_max_depth
):
    pass


cdef api godot_string pythonscript_debug_parse_stack_level_expression(
    godot_pluginscript_language_data *p_data,
    int p_level,
    const godot_string *p_expression,
    int p_max_subitems,
    int p_max_depth
):
    cdef godot_string ret
    cdef bytes src = b"Nothing"
    gdapi.godot_string_new_with_wide_string(&ret, <wchar_t*><char*>src, len(src))
    return ret


cdef api void pythonscript_get_public_functions(
    godot_pluginscript_language_data *p_data,
    godot_array *r_functions
):
    pass


cdef api void pythonscript_get_public_constants(
    godot_pluginscript_language_data *p_data,
    godot_dictionary *r_constants
):
    pass
