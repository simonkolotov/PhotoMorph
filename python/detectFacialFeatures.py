# USAGE
# python detect_face_parts.py --shape-predictor shape_predictor_68_face_landmarks.dat --image images/example_01.jpg 

# import the necessary packages
from imutils import face_utils
import numpy as np
import argparse
import imutils
import dlib
import cv2

class FaceSelector(object):
  """
  Selects a single face in an image based on a user input
  """

  def __init__(self, image, downsampleWidth = 500):
    """    
    Arguments:
    - `image`: the image in cv2 format
    - `downsampleWidth`: the width of image to downsample to if needed [500]
    """
    self.image = image

    # initialize dlib's face detector (HOG-based) and then create
    self.detector = dlib.get_frontal_face_detector()

    self.downsampleWidth = downsampleWidth

    try:
      self.DetectFace(self.image)
    except:
      #try another size?
      img500 = imutils.resize(self.image.copy(), width=self.downsampleWidth)
      r = float(self.image.shape[1]) / self.downsampleWidth
      
      self.DetectFace(img500)

      #don't forget to upsample back
      self.face = dlib.rectangle(int(self.face.left()  *r),
                                 int(self.face.top()   *r),
                                 int(self.face.right() *r),
                                 int(self.face.bottom()*r))

  def DetectFace(self, img):
    """
    Detect all faces in the image
    """

    #convert to grayscale
    grayImg = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

    # detect faces in the grayscale image
    faces = self.detector(grayImg, 1)

    if len(faces) == 0:
      raise Exception("No Faces Detected!") #TODO: Face Selection?

    elif len(faces) > 1:
      self.SelectSingleFace(img,faces)

      if self.face == None:
        raise Exception("No Face Selected!") #TODO: Skip photo

    else:
      self.face = faces[0]

  def SelectSingleFace(self, img, faces, downsampleWidth = None):
    """
    Select a single face out of all the ones available

    Arguments:
    - `faces`: the recognized rects of faces
    - `downsampleWidth`: the width of downsampled image to present if needed
    """
    #downsample the image for easier picking
    if downsampleWidth is None:
      downsampleWidth = self.downsampleWidth
    self.img500 = imutils.resize(img.copy(), width=downsampleWidth)

    #resizing ratio
    r = downsampleWidth / float(img.shape[1])

    #show downsampled image
    self.faceSelectionWin = "Select a Face";
    cv2.namedWindow(self.faceSelectionWin)

    self.rects = []
    for (rectId,rect) in enumerate(faces):
      
      # convert dlib's rectangle to a OpenCV-style bounding box
      # i.e., (x, y, w, h), remember to downsize the coordinates
      self.rects += [tuple([int(i*r) for i in face_utils.rect_to_bb(rect)])]

      cv2.putText(self.img500, "RET/SPC to select, q/SEC to quit", (10, 30), cv2.FONT_HERSHEY_SIMPLEX,
		  0.7, (0, 0, 255), 2)
      
    # create trackbar for face selection
    cv2.createTrackbar('Select a face',           #Title
                       self.faceSelectionWin,      #Window
                       1,                         #Selected Value
                       len(faces),                #Limits
                       self.UpdateRectColors) #Callback

    self.UpdateRectColors(1) #select the first face in the image

    # ESC key or selection to exit
    while (1):
      pressedKey=cv2.waitKey(20)

      if pressedKey in (113, 27):   #'q' or esc
        self.face = None
        return

      elif pressedKey in (13, 32): #enter, space
        selectedFace = cv2.getTrackbarPos('Select a face',self.faceSelectionWin)-1
        
        self.face = faces[selectedFace] if selectedFace >= 0 else None
        return

      elif pressedKey in (82, 83, 151, 152): #up/right
        cv2.setTrackbarPos('Select a face',self.faceSelectionWin,
                         cv2.getTrackbarPos('Select a face',self.faceSelectionWin)+1)

      elif pressedKey in (81, 84, 150, 153): #up/right
        cv2.setTrackbarPos('Select a face',self.faceSelectionWin,
                         cv2.getTrackbarPos('Select a face',self.faceSelectionWin)-1)
      
      elif pressedKey != -1:
        print ("Unknown key <{0}/{1}>".format(chr(pressedKey), pressedKey))

    cv2.destroyWindow(self.faceSelectionWin)

  #--- Utility functions ---
  def UpdateRectColors(self, selectedRectId):
    """
    Utility function for coloring selected face

    Arguments:
    - `selectedRectId`: the selected id of the face (1 based)
    """

    for (rectId, rect) in enumerate(self.rects):

      (x, y, w, h) = rect
      color = (0,255,0) if rectId == selectedRectId-1 else (0,0,255) #selection is 1 based

      cv2.rectangle(self.img500, (x, y), ((x + w), (y + h)), color, 2)

      # show the face number
      cv2.putText(self.img500,
                  "Face #{}".format(rectId + 1),
                  (x - 10, y - 10),
                  cv2.FONT_HERSHEY_SIMPLEX, 0.5, color, 2)

      cv2.imshow(self.faceSelectionWin, self.img500)


class FaceLandmarkDetector(object):
  """
  Finds face landmars in an ROI of an image
  """

  def __init__(self, predictor, image, roi, doPreviewResult = False):
    """
    Arguments:
    - `image`: the image in cv2 format
    - `roi`: the rectangle containing the selected face
    """
    self.image = image
    self.roi = roi

    self.predictor = dlib.shape_predictor(predictor)
    
    self.DetectLandmarks()

    if doPreviewResult:
      self.PreviewResult()

  def DetectLandmarks(self):
    """
    Detect the face landmarks within a face ROI
    """

    #convert to grayscale (again?)
    grayImg = cv2.cvtColor(self.image, cv2.COLOR_BGR2GRAY)
    self.points = face_utils.shape_to_np(self.predictor(grayImg, self.roi))

  def PreviewResult(self):
    """
    Preview the result of the facial landmark detection
    """
    output = face_utils.visualize_facial_landmarks(self.image, self.points)
    cv2.imshow("Landmarks", output)
    cv2.waitKey(0)
    
      
"""    
# loop over the face detections
for (i, rect) in enumerate(rects):
  # determine the facial landmarks for the face region, then
  # convert the landmark (x, y)-coordinates to a NumPy array
  shape = predictor(gray, rect)
  shape = face_utils.shape_to_np(shape)

  # loop over the face parts individually
for (name, (i, j)) in face_utils.FACIAL_LANDMARKS_IDXS.items():
    
    # clone the original image so we can draw on it, then
    # display the name of the face part on the image
    clone = image.copy()
    cv2.putText(clone, name, (10, 30), cv2.FONT_HERSHEY_SIMPLEX,
		0.7, (0, 0, 255), 2)

    # loop over the subset of facial landmarks, drawing the
    # specific face part
    for (x, y) in shape[i:j]:
      cv2.circle(clone, (x, y), 1, (0, 0, 255), -1)

      # extract the ROI of the face region as a separate image
      (x, y, w, h) = cv2.boundingRect(np.array([shape[i:j]]))
      roi = image[y:y + h, x:x + w]
      roi = imutils.resize(roi, width=250, inter=cv2.INTER_CUBIC)
      
    # show the particular face part
    cv2.imshow("ROI", roi)
    cv2.imshow("Image", clone)
    cv2.waitKey(0)
      
  # visualize all facial landmarks with a transparent overlay
  output = face_utils.visualize_facial_landmarks(image, shape)
  cv2.imshow("Image", output)
  cv2.waitKey(0)
"""

#-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
if __name__ == '__main__':

  # construct the argument parser and parse the arguments
  ap = argparse.ArgumentParser()
  ap.add_argument("-p", "--shape-predictor", default='shape_predictor_68_face_landmarks.dat',
	          help="path to facial landmark predictor")
  ap.add_argument("-i", "--image", required=True,
	          help="path to input image")
  args = vars(ap.parse_args())

  image = cv2.imread(args["image"])
  
  faceROI = FaceSelector(image).face

  interestPoints = FaceLandmarkDetector(args["shape_predictor"],
                                        image,
                                        faceROI,
                                        doPreviewResult = True).points