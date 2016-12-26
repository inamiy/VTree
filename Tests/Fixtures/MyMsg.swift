import VTree

enum MyMsg: String, Message
{
    case msg1, msg2, msg3, msg4
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
