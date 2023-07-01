draw_set_color(c_yellow)
draw_circle(x, y, 40, false)

draw_set_color(c_white)
draw_set_halign(fa_left)
draw_text(10, 10, string("{0}\n{1}\n{2}", text, move_and_return_text, shoot_green_fireworks_text))