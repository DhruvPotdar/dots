function px4_run
cd ~/drone_ws/Firmware && bass source ~/mav_ws/devel/setup.bash && bass source ~/drone_ws/Firmware/Tools/simulation/gazebo-classic/setup_gazebo.bash ~/drone_ws/Firmware ~/drone_ws/Firmware/build/px4_sitl_default &&  set -x ROS_PACKAGE_PATH $ROS_PACKAGE_PATH ~/drone_ws/Firmware ~/drone_ws/Firmware/Tools/simulation/gazebo-classic/sitl_gazebo-classic && cls
    echo "Do you want to run without GUI? (y/n)  "
    set user_input (read)
    
    if test "$user_input" = "y"
        roslaunch px4 iris.launch gui:=false
    else if test "$user_input" = "n"
        roslaunch px4 iris.launch gui:=true
    else
        # Default action for invalid input
        echo "Invalid input. Please enter 'y' or 'n'."
    end
end
