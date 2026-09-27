local startify = require("alpha.themes.startify")

startify.section.header.val = {
    "",
    "",
    "",
    "               +$: ;&;                                                                              ",
    "             $      :&                                                                              ",
    "           X:  ;+:                        X;;XX                                                     ",
    "          $    &      +xx;: ::     +Xx     ++   X                                                   ",
    "         ;x;   :&  +Xx:::              :&   +;   +;  Sometimes it is the people no one imagines anything",
    "         &X      xXx:: :::::              $; $    x  of who do the things that no one can imagine. ",
    "         XX : :;X;&+::::::: ::             :$     :                                                 ",
    "          &+ xX$ ++:;::+:::::        +$+$xXx      X            - Alan Turing                        ",
    "           ;&&::X::::;:::;;:::     :& :           $                                                 ",
    "            & x+::;+X$$X&X;:: :    &xx:+         $                                                  ",
    "           &+X:::;x$&&XXX++;       &&:&;X       X                                   :               ",
    "          &x :xx;x$&&&XXX+::       X&;& &:: + xX                                                    ",
    "         :& ++: :::;++::::::        :&&&&&&$&;  $                                                   ",
    "         X+X:: ;$X;;:;:::::;::                  +                                                   ",
    "         ;xx::Xx::::;::::+::                    x                                                   ",
    "          &X +X::::++XXXx;::                    &..                                                 ",
    "          ;&:;X;::xXx++::::::::                x ...                                                ",
    "           XX:X;:;xx;:::::::::     :          + ....                              x                 ",
    "            $:x+:xx:::::;;;;::               X;....                  x                  + x         ",
    "             ;&$x&:::;;xXXX;;:::: :        :+....+&x                 x  xx                 x        ",
    "             x&;$&&::+$X+::::::::: :     :+.........  ;$$:      :    x    x xxx                     ",
    "           &&&&+X$;;X&&$+;:::::    ;x$Xx:. ....Jakepys....  ;x$+:                  xX XXxX   x      ",
    "         x&&&&$x&&&XX;;+xX+++:       x: ....C.Programmig.  &&&x          x                   x       ",
    "        x&x&xX&$XXX+xxxXx:::::       :++   ...............   && &;           x                      ",
    "       x;:&+X+&$++x;xx;::::::     X  :::xx::   :$XX: ...   :X;XX                    x               ",
    "      +;:&;:$$Xx++xXXx:: ::      $X      ::: ::    X$     ;+ x:       :&;:+&:                       ",
    "      &;&::$&;++$&Xx+;::::       ;$;        :    ;:+:$   x& &        x;  ;&+x$   x                  ",
    "      &$:x&+++x&$++:+:::::    :  ++$    +::;+xx:Xx&&+&  $x&X        ;;  ;&&&&&x                     ",
    "      &:$&;+:xX++::;;:::;:        :X&:   :+;;X;x+:&&+X &x$&&;       &  +:     x&X                   ",
    "      &&;;:XX++;;+::::::::  :   ::.:x&x x:+x;X+&$$&$$&;;X   x+     :X +x&:&X:;++&                   ",
    "      X$:$x;+:;::+::::::::: :   :;xX&&&&&x+++&&&&$x   &::    &      $ x&&:&&::: &                   ",
    "      :&+&:+&x+;::::+::::.     ;+x$$X$&$;        X  + $:;   .X      & X:   xxX&&x                   ",
    "     +x&x$;&X++xX+;::::::                 + +    x  X $ ;+;$& :     & ;&$XX$&X+$;                   ",
    "      +X&X:X++X&&X++:::::  :           :  + x   x ;+;X ;;&   +: :: :&  $x:  ;X&:                    ",
    "  ;:   +&&X+++&x:::::::::  :           ; X :;; ; X:+x:  ++;:  :&;  ;;:x&&;;::;&;                    ",
    " +++    :;$$X$:+:;x$&x:x:         :  ;X x: X::&x$$;x+x+ :::+X:&+;+&X;&$;:   ;+&&                    ",
    " ;;+:    +X$;&+$&&x++::::::: :::: :;;& x: &:xxx&$;+&X;x; :& :$$    +&&X++&; ;&x$:                   ",
    "   X+      ;X;::&$X;::;:;::+&+;&++&X;;X;$&x:;$&xx+:   ;x :$  X$;x+:&&X+:::&:;$:$+ :::;              ",
    "   ;+;:   :;+;:  +XX;+X&&&&&&&&&&Xxxx;;:; xx;:;;;+X;:     Xx$&&&&&&&&+;+::& X:;&:+:;:               ",
    "                                                            :   :          ; ;                      ", "",
    "    [b] New Buffer         [0] Config"
}

startify.file_icons.provider = "mini"

startify.section.top_buttons.val = {
    startify.button("SPC f f", "Find file", ":lua MiniPick.builtin.files()<CR>"),
    startify.button("SPC f h", "Recently opened files", ":lua MiniExtra.pickers.oldfiles()<CR>"),
    startify.button("SPC f g", "Find word", ":lua MiniPick.builtin.grep_live()<CR>"),
    startify.button("SPC f m", "Jump to bookmarks", ":lua MiniExtra.pickers.marks()<CR>")
}

startify.section.footer.val = {
    startify.button("b", "New Buffer", ":enew<CR>"), startify.button("0", "Config", ":e ~/.config/nvim/init.lua<CR>")
}

require("alpha").setup(startify.config)
