import random
import turtle
from turtle import Turtle,Screen
screen = Screen()
screen.setup(width=600,height=600)
user_bet=screen.textinput(title="Make your bet",
                 prompt="Which turtle will win the race? Enter a color")

colors=["red","yellow","green","blue","purple","pink"]
po_y=[-150,-100,-50,0,50,100]

def draw_turtle(color_each,po_y):
    global colors
    t=Turtle(shape="turtle")
    t.color(color_each)
    t.penup()
    t.goto(-280, po_y)
    t.pendown()
    return t

all_turtles=[]
for i in range(0,6):
    turtle=draw_turtle(colors[i], po_y[i])
    all_turtles.append(turtle)

if user_bet:
    is_race_on=True

while is_race_on:
    for turtle in all_turtles:
        if turtle.xcor() > 280:
            is_race_on=False
            if user_bet==turtle.pencolor():
                print(f"You win! The color of winner is {turtle.color()}")
            else:
                print(f"You loss! The color of winner is {turtle.color()}")


        rand_distance=random.randint(0,10)
        turtle.penup()
        turtle.forward(rand_distance)






screen.exitonclick()