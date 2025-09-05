// lib/bloc/recording_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';

class RecordingBloc extends Bloc<RecordingEvent, RecordingState> {
  final RecordingRepository _repository;

  RecordingBloc(this._repository) : super(RecordingInitial()) {
    on<StartRecording>(_onStartRecording);
    on<StopRecording>(_onStopRecording);
    on<UploadVideo>(_onUploadVideo);
    on<CheckAnalysisStatus>(_onCheckAnalysisStatus);
  }

  Future<void> _onStartRecording(
    StartRecording event,
    Emitter<RecordingState> emit,
  ) async {
    try {
      emit(RecordingInProgress());
      // Start camera recording logic
    } catch (e) {
      emit(RecordingError(e.toString()));
    }
  }

  Future<void> _onUploadVideo(
    UploadVideo event,
    Emitter<RecordingState> emit,
  ) async {
    try {
      emit(UploadingVideo());
      
      final recording = await _repository.uploadVideo(
        videoPath: event.videoPath,
        sessionId: event.sessionId,
        testCategoryId: event.testCategoryId,
      );
      
      emit(VideoUploaded(recording));
      
      // Start polling for analysis results
      add(CheckAnalysisStatus(recording.id));
      
    } catch (e) {
      emit(RecordingError(e.toString()));
    }
  }
}