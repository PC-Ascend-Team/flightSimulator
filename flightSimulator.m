%------------------------------------------------------------------------
% Program name  : Flight Path Simulation/Motion Tracking
% Team          : Ursa Major Ascending Forward
% College       : Phoenix College
% Year          : 2015-16
% Author        : Oliver Salmeron
%
% Goal          : Collaborate post processing algorithms amongst teams to share,
% improve and optimtize code and analyzation. Read the License.txt for more info on the
% idea. 
%
% Description   : Matlab script for processing IMU data to simulate the flight motion. 
% 
% This program will open a text file containing flight data (roll,pitch,yaw) to rotate a 3D
% object. The result is saved as a movie named 'flightSimulation.mp4' within the same folder.
% This will help to visualize the motion tracking of a payload during the course of a flight.
% 
% To look up a MATLAB command, highlight command and press F1. Or, type:
% help "command" (without exclamations).
%
% Steps Outline :
%   1. Generate Grid.
%   2. Generate Cylinder and Frame vectors -- Used to create object.
%   3. Plot the Cylinder and Frame vectors -- Plot shapes.
%   4. Create a Group Object and Parent Surface -- Make object using shapes
%   5. Import 'flightData.txt' text file for reading -- include full file
%   path.
%   6. Open/Close text file to read and exctract data.
%   7. Parse imported data into temporary variables.
%   8. Create Video File to write to -- "flightSimulation".
%   9. For Loop -- Plot the frames and save to Video file.
%   10. Close Video File.
%
% To do's       : Add here
%
%-------------------------------------------------------------------------

%% 1. Generate Grid

clf
myaxes = axes('xlim',[-1.5 1.5],'ylim',[-1.5 1.5],'zlim',[-1.5 1.5]);
view(3)
grid on
hold on
xlabel('x')
ylabel('y')
zlabel('z')

% Additional Grid options
%axis square        % Adjusts plot axes to square
%axis equal         % Adjusts plot axes to equal
%axis off           % Removes axes grid

%% 2. Generate the Cylinder and frame vectors.

% draw the three coloured frame vectors
Lx = line([0 1.25],[0,0],[0,0],'color',[1,0,0]);
Ly = line([0 0],[0,1.25],[0,0],'color',[0,1,0]);
Lz = line([0 0],[0,0],[0,1.25],'color',[0,0,1]);
	
set([Lx,Ly,Lz],'linewidth',3)
    
% add text for x,y and z for each frame vector
tX = text('position',[.7 0 .1],'string','x','fontw','b');
tY = text('position',[ 0 .7 .1],'string','y','fontw','b');
tZ = text('position',[.05 0.05 .7],'string','z','fontw','b');
	
% draw the three axis vectors for reference (note the origin offset)
line([0,1.5],[0,0],[0,0],'color',[0,0,0],'linewidth',1);
line([0,0],[0,1.5],[0,0],'color',[0,0,0],'linewidth',1);
line([0,0],[0,0],[0,1.5],'color',[0,0,0],'linewidth',1);
	
% add text for x0,y0 and z0 for each base frame line
text('position',[1.3 0 .1],'string','x_0','fontw','b');
text('position',[ 0 1.3 .1],'string','y_0','fontw','b');
text('position',[.05 0.05 1.3],'string','z_0','fontw','b');

% create Cylinder
[X,Y,Z] = cylinder([0.75 0.75]);

% create Sphere
[S1,S2,S3] = sphere;
    
%% 3. Plot the shapes/Create the object

% Plot the cylinder (Body)	
h(1) = surf(X.*0.5,Y.*0.5,Z.*0.5);
h(2) = surf(-X.*0.5,-Y.*0.5,-Z.*0.5);

% Plot the Sphere (Bottom)
h(3)  = surf(S1.*0.375,S2.*0.375,S3.*0.375-0.5);

% Plot the Circle (Lid) using sphere
h(4) = surf(S1.*0.375,S2.*0.375,S3.*0+0.5);
h(5) = mesh(S1.*0.1,S2.*0.1,S3.*0.05+0.5);

%Set the colormap
colormap(gray)

% Plot the Base and Frame Vectors
h(6) = Lx;
h(7) = Ly;
h(8) = Lz;

h(9) = tX;
h(10) = tY;
h(11) = tZ;

% plot origin point at the center of the object
plot3(0,0,0,'x','markersize',20,'color','k')

%% 4. Create a group object and parent surface 
    
set(h,'Clipping','off');
combinedobject = hgtransform('parent',myaxes);
set(h, 'parent', combinedobject)
drawnow

%% 5. Import 'flightData' text file for reading. 

% Used the Import tool from the home tab to visually select data to extract from a
% file and then generate the following script. The data file can be named
% anything but it needs to be consistent with the filename.

%Initialize variables.

% Only the filename needs to be updated with the correct full file path.
filename = 'C:\Users\Oliver\Documents\GitHub\flightPathSimulator\flightData.txt';
delimiter = '\t';
startRow = 2;
    
% Format string for each line of text (formatSpec):
    %   column1: double (%f)
    %	column2: double (%f)
    %   column3: double (%f)
    %	column4: double (%f)
    %   column5: double (%f)
    %	column6: double (%f)
    %   column7: double (%f)
    % For more information, see the TEXTSCAN documentation.
    formatSpec = '%f%f%f%f%f%f%f%[^\n\r]';

%% 6. Open/Close text file to read and extract data

% Open the text file.
fileID = fopen(filename,'r');
    
% Read columns of data according to format string.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'EmptyValue' ,NaN,'HeaderLines' ,startRow-1, 'ReturnOnError', false);
    
% Close the text file.
fclose(fileID);

%%  7. Parse imported data into temporary variables.

% Allocate imported array to column variable names
Time = dataArray{:, 1};
roll = dataArray{:, 2};
pitch = dataArray{:, 3};
yaw = dataArray{:, 4};
%lat = dataArray{:, 5};
%lon = dataArray{:, 6};
%alt = dataArray{:, 7};
    
% Clear temporary variables
clearvars filename delimiter startRow formatSpec fileID dataArray ans;
    
%% 8. Create Video File to write to.
v = VideoWriter('flightSimulation.mp4','MPEG-4')         % Create an mp4 file type and display properties
v.FrameRate = 30;          % Change the Frame Rate of the exported video
open(v);
%axis tight manual
set(gca,'nextplot','replacechildren');

%% 9. For Loop -- Plot frames and write each frame to Video File.
% Define the conversion factors/global variables
    radians_degree = pi/180;    % Conversion factor from Degrees to Radians.

% For Loop
for Time = 1:7000     % Update limits of while loop to the desired Time frame

    % Read Euler angles (roll,pitch,yaw-->r,p,y).
    r = roll(Time);         % r <-- roll reading
    p = pitch(Time);        % p <-- pitch reading
    y = yaw(Time);          % y <-- yaw reading
        
    % Convert Euler angles to (X,Y,Z) axes rotations in radians.
    X = r*radians_degree;   % X <-- r
    Y = p*radians_degree;   % Y <-- p
    Z = y*radians_degree;   % Z <-- y
    
    % Create a Rotatation Matrix using axes rotations
    Rot = makehgtform('xrotate',X,'yrotate',Y,'zrotate',Z);
    set(combinedobject,'Matrix',Rot)
  
    % New Plot
    drawnow;
    pause(0.01);            % Change the plot rate of MATLAB animation (not video)
    
    axis([-1.5 1.5 -1.5 1.5 -1.5 1.5])  % Set the axis for each frame of the loop for recording a movie
    frame = getframe;       % Get frame
    writeVideo(v,frame);    % Save frame to Video. Rename afterwards for description.
   
    Time=Time+1;            % Increment the for loop
end

%% 10. Close video
close(v);