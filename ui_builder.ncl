{
  build_full = fun namespace class id children => 
    let 
        properties = let h  = 
            if array.length children > 0
            then array.head children 
            else null in 
            if h != null && !record.has_field "_ui" h 
            then h 
            else null
    in
    {
    _ui._type = `Object,
    _ui.namespace = namespace,
    _ui.id = id,
    _ui.class = namespace ++ string.from_enum class,
    _ui.properties = if properties == null then {} else properties,
    _ui.children = if properties == null then children else array.tail children,
    },
  build
   = fun namespace class id_or_children => if !builtin.is_array id_or_children && !builtin.is_record id_or_children
    then (fun children => build_full namespace class id_or_children children)
    else build_full namespace class null id_or_children,
  child_type = fun t child => child & {_ui.child_type = t},
  children = fun ls => {
    _ui.children = ls
  },
  entries = fun r => array.map (fun f => [f, r."%{f}"]) (record.fields r),
  margins = fun s => {margin-top = s, margin-bottom = s, margin-start = s, margin-end = s},
  style = fun style => {_ui._type = `Style, _ui.style = style},
  to_property_value_xml = fun val => 
    if builtin.is_record val && record.has_field "_ui" val && val._ui._type == `Object 
      then to_object_xml val 
      else string.from_enum val,
  to_property_xml = fun prop => m%"
    <property name="%{string.from_enum (array.elem_at 0 prop)}">%{to_property_value_xml (array.elem_at 1 prop)}</property>
  "%m,
  to_child_xml = fun child => if child._ui._type == `Object then
    m%"
    <child%{if record.has_field "child_type" child._ui then " " ++ m%"type="%{string.from_enum child._ui.child_type}""%m else ""}>
      %{to_object_xml child}
    </child>
    "%m else if child._ui._type == `Attributes then m%"
    <attributes>
      %{string.join "\n" (array.map (fun entry => m%"<attribute name="%{array.elem_at 0 entry}" value="%{string.from_enum (array.elem_at 1 entry)}"/> "%m) (entries child._ui.attributes))}
    </attributes>    
    "%m else if child._ui._type == `Signal then let {object, handler, name, swapped} = child._ui.signal in m%"
    <signal name="%{string.from_enum name}" handler="%{string.from_enum handler}" swapped="%{string.from_enum swapped}" object="%{string.from_enum object}"/>
    "%m else if child._ui._type == `Style then m%"
    <style>%{array.map (fun s => m%"<class name="%{string.from_enum s}"/>"%m) child._ui.style |> string.join "\n" }</style>
    "%m else "",
  to_object_xml = fun obj => m%"
    <%{if obj._ui._type == `Template then m%"template parent="%{obj._ui.parent}""%m else "object"} class="%{obj._ui.class}"%{if obj._ui.id != null then " " ++ m%"id="%{string.from_enum obj._ui.id}""%m else ""}>
        %{array.map to_property_xml (entries obj._ui.properties) |> string.join "\n" }
        %{array.map to_child_xml obj._ui.children |> string.join "\n"}
    </%{if obj._ui._type == `Template then "template" else "object"}>
  "%m,
  to_builder_xml = fun desc => 
  m%"
    <?xml version="1.0" encoding="UTF-8"?>  
    <interface>
    %{array.map to_object_xml desc |> string.join "\n"}
    </interface>
  "%m,
  template = fun class desc => record.update "_ui" (record.update "class" (string.from_enum class) desc._ui |> record.update "_type" `Template) desc & {_ui.parent = desc._ui.class},
  attributes 
     = fun desc => {
      _ui._type = `Attributes,
      _ui.attributes = desc
  },
  signal 
     = fun desc => {
      _ui._type = `Signal,
      _ui.signal = desc,
  },
}

