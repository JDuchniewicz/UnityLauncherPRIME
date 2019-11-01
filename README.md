# Unity Launcher PRIME

A launcher script for UnityHub for users of NVidia PRIME. This overcomes the problem of Unity projects always using integrated GPU even though `__NV_PRIME_RENDER_OFFLOAD=1` is passed as environment variable, script allows for customized launching of Unity projects on Unix machines from command line. 

## Getting Started

1. Clone this repository `https://github.com/JDuchniewicz/UnityLauncherPRIME.git`
2. Add execute permissions `chmod +x unityEditor.sh`
3. Run to see options `./unityEditor.sh -h`

### Prerequisites

This script requires following environment variables to be set

- UNITY_EDITOR_LOCATION - location of Unity editors (folder where different versions can be found)
- UNITY_PROJECTS_LOCATION - location of your Unity projects

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details
