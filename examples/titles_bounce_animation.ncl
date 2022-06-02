let {to_builder_xml, template, child_type, build, style, attributes, signal, margins, ..} = import "../ui_builder.ncl" in
let Gtk = build "Gtk" in
let Adw = build "Adw" in
let numbers = array.map (fun i => (i + 2) / 2) (array.generate function.id 10) in
let animation_signal = fun nname i => 
  signal { name = nname, object = "animation%{string.from_num i}", handler = "play", swapped = "no", }
in
let label_id = fun i => "label%{string.from_num i}" in
to_builder_xml ([
    template `NickeltestWindow (Gtk `ApplicationWindow ([
        { 
            default-height = 600,
            default-width = 1280
        },
        Gtk `HeaderBar `header_bar [
          Gtk `Button `button [
              { icon-name = "open-menu-symbolic" }
          ] |> child_type `end
        ] |> child_type `titlebar,
        Gtk `Box ([
          { 
              orientation = `vertical,
          } & margins 16,
          Gtk `Button ([
              {label = "Animate!", margin-bottom = 16},
              style ["pill", "suggested-action"]
          ] @ array.map (animation_signal "clicked") numbers),
        ] @ array.map (fun size => 
            Gtk `Label (label_id size) [
                {
                    label = "Hello, World!",
                    xalign = 0
                },
                attributes {
                    scale = size,     
                    weight = "bold",
                },
                animation_signal "map" size
            ]
          ) numbers)
        ])
    ),
] @ array.map (fun n => Adw `TimedAnimation "animation%{string.from_num n}" [
    {
        widget = label_id n,
        duration = 1000 + n*300,
        value-from = 0,
        value-to = 240,
        alternate = true,
        easing = `ease-out-elastic,
        repeat-count = 2,
        target = Adw `PropertyAnimationTarget [
            { 
              object = widget,
              property-name = `margin-start
            }               
        ]
    }  
]) numbers)