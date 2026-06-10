from turtle import Turtle,Screen

tim = Turtle()
tim.shape("turtle")
tim.color("red")
tim.setheading(225)
tim.penup()
tim.forward(300)
tim.setheading(0)

tony = Turtle()
tony.shape("turtle")
tony.color("blue")


# def move_forwards():
#     tim.forward(10)
#
# def backward():
#     tim.backward(10)
#
# def counterclockwise():
#     new_heading=tim.heading()+10
#     tim.setheading(new_heading)
#
# def clockwise():
#     new_heading = tim.heading() - 10
#     tim.setheading(new_heading)
# def clear():
#     tim.clear()
#     tim.penup()
#     tim.home()
#     tim.pendown()
#
#
# screen.listen()
# screen.onkey(move_forwards,'W')
# screen.listen()
# screen.onkey(backward,'S')
# screen.listen()
# screen.onkey(counterclockwise,'A')
# screen.listen()
# screen.onkey(clockwise,'D')
# screen.listen()
# screen.onkey(clear,'C')
screen = Screen()
screen.exitonclick()
