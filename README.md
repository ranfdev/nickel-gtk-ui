# nickel-gtk-ui
gtk .ui DSL written in [nickel]. - Alpha, test project -

The following ui was decleared in only 59 lines, animations included.

https://user-images.githubusercontent.com/23294184/171616820-ec34d959-20da-4f63-a9bf-3039e5aa82f2.mp4


## Why?
Frustrated by the standard .ui file writing experience (that xml is very verbose) and inspired by the [blueprint compiler](https://gitlab.gnome.org/jwestman/blueprint-compiler), I've decided to write a custom Domain Specific Language to generate .ui files. Compared to blueprint compiler, this let's you use a complete programming language, with variables and functions, to generate your ui. 

If you squint hard enough, gtk builder .ui files are configuration files. [nickel] is a programming language created specifically to generate configuration files. Because of that, I've decided to write the DSL in nickel.

Nickel supports type checks and contract, so this DSL could have type checks in the future.

## Example
See the [examples directory](./examples) or the example below.

This will generate the ui you can see in the video above.
Notice: this file is ~60 lines long, while the generated .ui file is 305 lines long. This DSL will drastically reduce the code you need to write :).

```nickel
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
```

This python file builds the widget from the .ui file.

```py
@Gtk.Template(filename='./src/window.ui')
class NickeltestWindow(Gtk.ApplicationWindow):
    __gtype_name__ = 'NickeltestWindow'
    @Gtk.Template.Callback()
    def play(_, target):
        Adw.TimedAnimation.play(target)

    def __init__(self, **kwargs):
        super().__init__(**kwargs)
```

## Get started

- Download [nickel]
- Run
```bash
git clone https://github.com/ranfdev/nickel-gtk-ui.git
cd nickel-gtk-ui
nickel export -f examples/titles_bounce_animation.ncl --format raw > generated.ui`
```



[nickel]: https://github.com/tweag/nickel
