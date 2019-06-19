{%- macro iter_singletons(classes) -%}
{%- for cls in classes -%}
{%- if cls["singleton"] -%}
{{ caller(cls) }}
{%- endif -%}
{%- endfor -%}
{%- endmacro -%}

{%- call(cls) iter_singletons(classes) %}
{{ cls["singleton_name"] }} = {{ cls["name"] }}.from_ptr(
	godot_global_get_singleton("{{ cls['singleton_name'] }}")
)
{%- endcall %}