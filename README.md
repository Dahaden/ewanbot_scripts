ewanbot_cripts
==============

Give me scripts!


#How To

Start with:
`module.exports = (robot) ->`
then,
`robot.hear` or `robot.respond`
(hear for any case, reply if you only want it called when you ask ewanbot)
followed by some regex `/\S+/` (What you want to match)
`msg.send` to return a message
