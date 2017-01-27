import VTree

enum MyMsg: AutoMessage
{
    case msg1, msg2, msg3, msg4
}

enum MyMsg2: AutoMessage
{
    case test1, test2
}

enum MyGestureMsg: AutoMessage
{
    case msg1(GestureContext)
    case msg2(GestureContext)
    case msg3(GestureContext)
    case msg4(GestureContext)
}

enum MyGestureMsg2: AutoMessage
{
    case msg1(GestureContext)
    case msg2(GestureContext)
    case msg3(GestureContext)
    case msg4(GestureContext)
}
