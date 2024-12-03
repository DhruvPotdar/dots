function catkinSource --on-variable PWD
    status --is-command-substitution; and return
    if test -e ".catkin_workspace"
        if test "$ROS_VERSION" = "1"
            bass source /opt/ros/noetic/setup.bash
            bass source devel/setup.bash
            echo "Configured the folder as a ROS1 workspace"
        else if test "$ROS_VERSION" = "2"
            bass source /opt/ros/humble/setup.bash
            bass source install/local_setup.bash
            echo "Configured the folder as a ROS2 workspace"
        end
    end
end
