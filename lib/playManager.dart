
import 'package:audio_session/audio_session.dart';
import 'package:freemusic_flutter/common.dart';
import 'package:freemusic_flutter/musicModel.dart';
import 'package:rxdart/rxdart.dart';
import 'networkManager.dart';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';


class PlayerManger {
  List playMusicList;
  int playingIndex;
  bool isPlaying = false;
  static final PlayerManger _manger = new PlayerManger.internal();

  factory PlayerManger() => _manger;
  // static AudioPlayer _player;
  AudioPlayerHandler _audioHandler;

  void Function(MusicModel model) onStartPlay;

  PlayerManger.internal();

  // AudioPlayer get player {
  //   if (_player != null) return _player;
  //   _player = initPlayer();
  //   return _player;
  // }

  AudioHandler get audioHandler {
    if (_audioHandler != null) return _audioHandler;
    registerAudioService();
    return _audioHandler;
  }

  initPlayer() {
    AudioPlayer audioPlayer = AudioPlayer();
    return audioPlayer;
  }

  Future<void> registerAudioService() async {
    _audioHandler = await AudioService.init(
    builder: () => AudioPlayerHandlerImpl(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.erik.freemusic',
      androidNotificationChannelName: 'Audio playback',
      androidNotificationOngoing: true,
    ),
  );
  } 

  void playNext() {
    // playingIndex++;
    if (playingIndex == playMusicList.length - 1) {
      playingIndex = 0;
      audioHandler.skipToQueueItem(playingIndex);
    } else {
      audioHandler.skipToNext();
      playingIndex++;
    }
    // reloadPlayDataWithIndex();
  }

  void playPrevious() {
    if (playingIndex == 0) {
      playingIndex = playMusicList.length - 1;
      audioHandler.skipToQueueItem(playingIndex);
    } else {
      audioHandler.skipToPrevious();
      playingIndex--;
      
    }
    // reloadPlayDataWithIndex();
  }

  void play() {
    // player.play();
    _audioHandler.play();
    isPlaying = true;
  }

  void pause() {
    _audioHandler.pause();
    isPlaying = false;
  }

  void playAndPause() {
    // if (!_audioHandler.playbackState.) {
    //   play();
    // } else {
    //   pause();
    // }
  }

  void reloadPlayDataWithIndex(int index) async {
    MusicModel model = playMusicList[index];
    playingIndex = index;
    String musicUrl =
        await NetworkManager().requestMusicUrlWithId(model);
    MediaItem item = MediaItem(
        id: model.url,
        album: null,
        title: model.title,
        artist: model.author,
        duration: const Duration(milliseconds: 0),
        artUri: Uri.parse(model.pic)
      );
    audioHandler.skipToQueueItem(index);
    audioHandler.play();

    onStartPlay(playMusicList[playingIndex]);
    // _audioHandler.play();
    // _audioHandler.play();
    // _audioHandler.addQueueItem(item);
    
    // reloadPlayDataWithUrl(musicUrl);
  }

  void reloadPlayDataWithModel(MusicModel model) async {

    MediaItem item = MediaItem(
        id: model.url,
        album: "",
        title: model.title,
        artist: model.author,
        duration: await AudioPlayer().setUrl(model.url),
        artUri: Uri.parse(model.pic)
      );
    audioHandler.updateQueue([item]);
    // audioHandler.play();
    // _audioHandler.playMediaItem(item);
    // await _audioHandler.stop();
    // _audioHandler.playMediaItem(item);
    onStartPlay(playMusicList[playingIndex]);
    isPlaying = true;
    // _audioHandler.playFromUri(Uri.parse("http:\/\/music.163.com\/song\/media\/outer\/url?id=1484876187.mp3")); 
  }

  void addPlayQueue(List<MusicModel> queue,int index) async {
    List<MediaItem> items = [];
    for (var model in queue) {
      MediaItem item = MediaItem(
        id: model.url,
        album: "",
        title: model.title,
        artist: model.author,
        duration: await AudioPlayer().setUrl(model.url),
        artUri: Uri.parse(model.pic)
      );
      items.add(item);
    }
    audioHandler.addQueueItems(items);
  }

  void reloadPlayDataWithUrl(String fileUrl) async {
    _audioHandler.pause();
    onStartPlay(playMusicList[playingIndex]);
    if (fileUrl == '') {
      isPlaying = false;
      return;
    }
    // player.setUrl(fileUrl);

    // if (player.playing) {
    //   isPlaying = true;
    //   print('正在播放');
    // }
  }
}

class MediaState {
  final MediaItem mediaItem;
  final Duration position;

  MediaState(this.mediaItem, this.position);
}

class QueueState {
  static const QueueState empty =
      QueueState([], 0, [], AudioServiceRepeatMode.none);

  final List<MediaItem> queue;
  final int queueIndex;
  final List<int> shuffleIndices;
  final AudioServiceRepeatMode repeatMode;

  const QueueState(
      this.queue, this.queueIndex, this.shuffleIndices, this.repeatMode);

  bool get hasPrevious =>
      repeatMode != AudioServiceRepeatMode.none || (queueIndex ?? 0) > 0;
  bool get hasNext =>
      repeatMode != AudioServiceRepeatMode.none ||
      (queueIndex ?? 0) + 1 < queue.length;

  List<int> get indices =>
      shuffleIndices ?? List.generate(queue.length, (i) => i);
}

/// An [AudioHandler] for playing a list of podcast episodes.
///
/// This class exposes the interface and not the implementation.
abstract class AudioPlayerHandler implements AudioHandler {
  Stream<QueueState> get queueState;
  Future<void> moveQueueItem(int currentIndex, int newIndex);
  ValueStream<double> get volume;
  Future<void> setVolume(double volume);
  ValueStream<double> get speed;
}

/// The implementation of [AudioPlayerHandler].
///
/// This handler is backed by a just_audio player. The player's effective
/// sequence is mapped onto the handler's queue, and the player's state is
/// mapped onto the handler's state.
class AudioPlayerHandlerImpl extends BaseAudioHandler
    with SeekHandler
    implements AudioPlayerHandler {
  // ignore: close_sinks
  final BehaviorSubject<List<MediaItem>> _recentSubject =
      BehaviorSubject.seeded(<MediaItem>[]);
  final _mediaLibrary = MediaLibrary();
  final _player = AudioPlayer();
  final _playlist = ConcatenatingAudioSource(children: []);
  @override
  final BehaviorSubject<double> volume = BehaviorSubject.seeded(1.0);
  @override
  final BehaviorSubject<double> speed = BehaviorSubject.seeded(1.0);
  final _mediaItemExpando = Expando<MediaItem>();

  /// A stream of the current effective sequence from just_audio.
  Stream<List<IndexedAudioSource>> get _effectiveSequence => Rx.combineLatest3<
              List<IndexedAudioSource>,
              List<int>,
              bool,
              List<IndexedAudioSource>>(_player.sequenceStream,
          _player.shuffleIndicesStream, _player.shuffleModeEnabledStream,
          (sequence, shuffleIndices, shuffleModeEnabled) {
        if (sequence == null) return [];
        if (!shuffleModeEnabled) return sequence;
        if (shuffleIndices == null) return null;
        if (shuffleIndices.length != sequence.length) return null;
        return shuffleIndices.map((i) => sequence[i]).toList();
      }).whereType<List<IndexedAudioSource>>();

  /// Computes the effective queue index taking shuffle mode into account.
  int getQueueIndex(
      int currentIndex, bool shuffleModeEnabled, List<int> shuffleIndices) {
    final effectiveIndices = _player.effectiveIndices ?? [];
    final shuffleIndicesInv = List.filled(effectiveIndices.length, 0);
    for (var i = 0; i < effectiveIndices.length; i++) {
      shuffleIndicesInv[effectiveIndices[i]] = i;
    }
    return (shuffleModeEnabled &&
            ((currentIndex ?? 0) < shuffleIndicesInv.length))
        ? shuffleIndicesInv[currentIndex ?? 0]
        : currentIndex;
  }

  /// A stream reporting the combined state of the current queue and the current
  /// media item within that queue.
  @override
  Stream<QueueState> get queueState =>
      Rx.combineLatest3<List<MediaItem>, PlaybackState, List<int>, QueueState>(
          queue,
          playbackState,
          _player.shuffleIndicesStream.whereType<List<int>>(),
          (queue, playbackState, shuffleIndices) => QueueState(
                queue,
                playbackState.queueIndex,
                playbackState.shuffleMode == AudioServiceShuffleMode.all
                    ? shuffleIndices
                    : null,
                playbackState.repeatMode,
              )).where((state) =>
          state.shuffleIndices == null ||
          state.queue.length == state.shuffleIndices.length);

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    final enabled = shuffleMode == AudioServiceShuffleMode.all;
    if (enabled) {
      await _player.shuffle();
    }
    playbackState.add(playbackState.value.copyWith(shuffleMode: shuffleMode));
    await _player.setShuffleModeEnabled(enabled);
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    playbackState.add(playbackState.value.copyWith(repeatMode: repeatMode));
    await _player.setLoopMode(LoopMode.values[repeatMode.index]);
  }

  @override
  Future<void> setSpeed(double speed) async {
    this.speed.add(speed);
    await _player.setSpeed(speed);
  }

  @override
  Future<void> setVolume(double volume) async {
    this.volume.add(volume);
    await _player.setVolume(volume);
  }

  AudioPlayerHandlerImpl() {
    _init();
  }

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
    // Broadcast speed changes. Debounce so that we don't flood the notification
    // with updates.
    speed.debounceTime(const Duration(milliseconds: 250)).listen((speed) {
      playbackState.add(playbackState.value.copyWith(speed: speed));
    });
    // Load and broadcast the initial queue
    await updateQueue(_mediaLibrary.items[MediaLibrary.albumsRootId]);
    // For Android 11, record the most recent item so it can be resumed.
    mediaItem
        .whereType<MediaItem>()
        .listen((item) => _recentSubject.add([item]));
    // Broadcast media item changes.
    Rx.combineLatest4<int, List<MediaItem>, bool, List<int>, MediaItem>(
        _player.currentIndexStream,
        queue,
        _player.shuffleModeEnabledStream,
        _player.shuffleIndicesStream,
        (index, queue, shuffleModeEnabled, shuffleIndices) {
      final queueIndex =
          getQueueIndex(index, shuffleModeEnabled, shuffleIndices);
      return (queueIndex != null && queueIndex < queue.length)
          ? queue[queueIndex]
          : null;
    }).whereType<MediaItem>().distinct().listen(mediaItem.add);
    // Propagate all events from the audio player to AudioService clients.
    _player.playbackEventStream.listen(_broadcastState);
    _player.shuffleModeEnabledStream
        .listen((enabled) => _broadcastState(_player.playbackEvent));
    // In this example, the service stops when reaching the end.
    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        stop();
        _player.seek(Duration.zero, index: 0);
        PlayerManger().playNext();
      }
    });
    // Broadcast the current queue.
    _effectiveSequence
        .map((sequence) =>
            sequence.map((source) => _mediaItemExpando[source]).toList())
        .pipe(queue);
    // Load the playlist.
    _playlist.addAll(queue.value.map(_itemToSource).toList());
    await _player.setAudioSource(_playlist);
  }

  AudioSource _itemToSource(MediaItem mediaItem) {
    final audioSource = AudioSource.uri(Uri.parse(mediaItem.id));
    _mediaItemExpando[audioSource] = mediaItem;
    return audioSource;
  }

  List<AudioSource> _itemsToSources(List<MediaItem> mediaItems) =>
      mediaItems.map(_itemToSource).toList();

  @override
  Future<List<MediaItem>> getChildren(String parentMediaId,
      [Map<String, dynamic> options]) async {
    switch (parentMediaId) {
      case AudioService.recentRootId:
        // When the user resumes a media session, tell the system what the most
        // recently played item was.
        return _recentSubject.value;
      default:
        // Allow client to browse the media library.
        return _mediaLibrary.items[parentMediaId];
    }
  }

  @override
  ValueStream<Map<String, dynamic>> subscribeToChildren(String parentMediaId) {
    switch (parentMediaId) {
      case AudioService.recentRootId:
        final stream = _recentSubject.map((_) => <String, dynamic>{});
        return _recentSubject.hasValue
            ? stream.shareValueSeeded(<String, dynamic>{})
            : stream.shareValue();
      default:
        return Stream.value(_mediaLibrary.items[parentMediaId])
            .map((_) => <String, dynamic>{})
            .shareValue();
    }
  }

  @override
  Future<void> addQueueItem(MediaItem mediaItem) async {
    await _playlist.add(_itemToSource(mediaItem));
  }

  @override
  Future<void> addQueueItems(List<MediaItem> mediaItems) async {
    if (_player.playing)
      _player.stop();
    _player.seek(Duration.zero,index: 0);
    await _playlist.clear();
    await _playlist.addAll(_itemsToSources(mediaItems));
    skipToQueueItem(PlayerManger().playingIndex);
    _player.play();
  }

  @override
  Future<void> insertQueueItem(int index, MediaItem mediaItem) async {
    await _playlist.insert(index, _itemToSource(mediaItem));
  }

  @override
  Future<void> updateQueue(List<MediaItem> queue) async {
    if (_player.playing)
      _player.stop();
    _player.seek(Duration.zero,index: 0);
    await _playlist.clear();
    await _playlist.addAll(_itemsToSources(queue));
    _player.play();
  }

  @override
  Future<void> updateMediaItem(MediaItem mediaItem) async {
    final index = queue.value.indexWhere((item) => item.id == mediaItem.id);
    _mediaItemExpando[_player.sequence[index]] = mediaItem;
  }

  @override
  Future<void> removeQueueItem(MediaItem mediaItem) async {
    final index = queue.value.indexOf(mediaItem);
    await _playlist.removeAt(index);
  }

  @override
  Future<void> moveQueueItem(int currentIndex, int newIndex) async {
    await _playlist.move(currentIndex, newIndex);
  }

  @override
  Future<void> skipToNext() => _player.seekToNext();

  @override
  Future<void> skipToPrevious() => _player.seekToPrevious();

  @override
  Future<void> skipToQueueItem(int index) async {
    if (index < 0 || index >= _playlist.children.length) return;
    // This jumps to the beginning of the queue item at [index].
    _player.seek(Duration.zero,
        index: _player.shuffleModeEnabled
            ? _player.shuffleIndices[index]
            : index);
    _player.play();
    
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> stop() async {
    await _player.stop();
    await playbackState.firstWhere(
        (state) => state.processingState == AudioProcessingState.idle);
  }

  Future<Duration> getMuicDuration(String url) async {
    if (url == null)
      return Duration(milliseconds: 0);
    return  _player.setUrl(url);
  }

  /// Broadcasts the current state to all clients.
  void _broadcastState(PlaybackEvent event) {
    final playing = _player.playing;
    final queueIndex = getQueueIndex(
        event.currentIndex, _player.shuffleModeEnabled, _player.shuffleIndices);
    playbackState.add(playbackState.value.copyWith(
      controls: [
        MediaControl.skipToPrevious,
        if (playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 3],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState],
      playing: playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: queueIndex,
    ));
  }
}

/// Provides access to a library of media items. In your app, this could come
/// from a database or web service.
class MediaLibrary {
  static const albumsRootId = 'albums';

  final items = <String, List<MediaItem>>{
    AudioService.browsableRootId: const [
      MediaItem(
        id: albumsRootId,
        title: "Albums",
        playable: false,
      ),
    ],
    albumsRootId: [
      // MediaItem(
      //   id: '',
      //   album: "享乐",
      //   title: " 享乐音乐",
      //   artist: "Erik",
      //   duration: const Duration(milliseconds: 0),
      //   artUri: Uri.parse(
      //       ''),
      // ),
      // MediaItem(
      //   id: 'https://s3.amazonaws.com/scifri-segments/scifri201711241.mp3',
      //   album: "Science Friday",
      //   title: "From Cat Rheology To Operatic Incompetence",
      //   artist: "Science Friday and WNYC Studios",
      //   duration: const Duration(milliseconds: 0),
      //   artUri: Uri.parse(
      //       'https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg'),
      //   playable:false
      // ),
      // MediaItem(
      //   id: 'https://s3.amazonaws.com/scifri-segments/scifri202011274.mp3',
      //   album: "Science Friday",
      //   title: "Laugh Along At Home With The Ig Nobel Awards",
      //   artist: "Science Friday and WNYC Studios",
      //   duration: const Duration(milliseconds: 1791883),
      //   artUri: Uri.parse(
      //       'https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg'),
      // ),
    ],
  };
}
