# ai_processor.py
import cv2
import mediapipe as mp
import numpy as np
from tensorflow.lite import Interpreter

class VideoAnalyzer:
    def __init__(self):
        self.mp_pose = mp.solutions.pose
        self.pose = self.mp_pose.Pose()
        self.mp_drawing = mp.solutions.drawing_utils
    
    def analyze_vertical_jump(self, video_path):
        """Analyze vertical jump performance"""
        cap = cv2.VideoCapture(video_path)
        jump_heights = []
        
        while cap.isOpened():
            ret, frame = cap.read()
            if not ret:
                break
                
            # Process frame with MediaPipe
            results = self.pose.process(cv2.cvtColor(frame, cv2.COLOR_BGR2RGB))
            
            if results.pose_landmarks:
                # Extract hip position for jump height calculation
                hip = results.pose_landmarks.landmark[self.mp_pose.PoseLandmark.LEFT_HIP]
                jump_heights.append(hip.y)
        
        cap.release()
        
        # Calculate max jump height
        baseline = np.median(jump_heights[:30])  # Standing position
        max_height = min(jump_heights)  # Lowest y-value = highest jump
        jump_height_cm = (baseline - max_height) * 180  # Convert to cm (approximate)
        
        return {
            'jump_height': jump_height_cm,
            'confidence': 0.85,
            'analysis_data': {
                'baseline_position': baseline,
                'peak_position': max_height,
                'total_frames': len(jump_heights)
            }
        }
    
    def analyze_situps(self, video_path):
        """Count sit-ups and validate form"""
        cap = cv2.VideoCapture(video_path)
        rep_count = 0
        positions = []
        
        while cap.isOpened():
            ret, frame = cap.read()
            if not ret:
                break
                
            results = self.pose.process(cv2.cvtColor(frame, cv2.COLOR_BGR2RGB))
            
            if results.pose_landmarks:
                # Calculate torso angle
                shoulder = results.pose_landmarks.landmark[self.mp_pose.PoseLandmark.LEFT_SHOULDER]
                hip = results.pose_landmarks.landmark[self.mp_pose.PoseLandmark.LEFT_HIP]
                knee = results.pose_landmarks.landmark[self.mp_pose.PoseLandmark.LEFT_KNEE]
                
                angle = self.calculate_angle(shoulder, hip, knee)
                positions.append(angle)
        
        cap.release()
        
        # Count complete repetitions
        rep_count = self.count_repetitions(positions, threshold_up=160, threshold_down=90)
        
        return {
            'rep_count': rep_count,
            'confidence': 0.90,
            'analysis_data': {
                'angle_sequence': positions,
                'total_frames': len(positions)
            }
        }