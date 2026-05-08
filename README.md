# Galactic Traffic 

## Video:
[![Watch the playthrough commentary video](https://github.com/user-attachments/assets/7dd37ccb-29be-497f-96a9-888a1c8f7fb7)](https://www.youtube.com/watch?v=SRFbMyrE17k)

## Description
In this game you play as a traffic guard for the intergalactic alien traffic, to guide spaceships to their destinations and help with the great galactic expansion. Your job is to steer the leaders of each flock of spaceships into the correct cardinal direction of the screen. As the rounds progress, it becomes more and more difficult to guide the ships, with flocks needing to be guided simultaneously and hazard obstacles that fly in the way.
You need to be careful of other flocks colliding together or colliding into hazards like asteroids. All of these mechanics help add to the chaos of the gameplay, where you must minimise the damage caused to all the ships to increase your final score.

## What did we learn:
Throughout the semester we learned the boid behaviours and how they would interact, but to implement them in an assignment is a different tasks altogether. It required tweaking of the boid parameters to protray a convincing sense of life. The assignment also forced us to test out each boid behaviour to choose which one would best suit the fleets of spaceships. We also familiarised with other parts of the Godot engine such as using sprite sheets to animate our characters on the screen, using shaders to apply a CRT shader to these animated characters and using the audio stream player to create an 'animal crossing' sound effect by randomly increasing and decreasing the pitch when dialog is onscreen.

For this game, it was made using our previous experience with Godot, which is why it was so important to create a node structure that seperates code into independent components, which could be added or removed for additional functionality such as the grabbable component. Keeping everything seperated but linked together using signals helped reduce dependencies and allow us to make changes to the code without breaking outside components as easily. Factories were a core aspect of this project, for composing and handling the ship fleets, asteroids, energy balls and wormholes. We learned to use the export variables for easily tweaking the number of spawned entities, the spawn radius and spawn rates too.

## Sources:
| Asset Name | Link |
|--|--|
| CRT Shader | https://godotshaders.com/shader/vhs-and-crt-monitor-effect-2/ |
| Space Assets | https://kenney.nl/assets/space-kit |
| Various sound effects | https://freesound.org/ |
