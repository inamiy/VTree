import VTree

enum MyMsg: String, Message
{
    case msg1, msg2, msg3, msg4
}

// sourcery: VTreeMessage
enum MyGestureMsg
{
    case msg1(GestureContext)
    case msg2(GestureContext)
    case msg3(GestureContext)
    case msg4(GestureContext)
}

// sourcery: VTreeMessage
enum MyGestureMsg2
{
    case msg1(GestureContext)
    case msg2(GestureContext)
    case msg3(GestureContext)
    case msg4(GestureContext)
}
