export interface VideoClip {
  id: string;
  title: string;
  source: Resource;
}

export const VIDEO_CLIPS: VideoClip[] = [
  { id: 'shaoen', title: '课程视频 01', source: $rawfile('shaoen.mp4') },
  { id: 'shaoen2', title: '课程视频 02', source: $rawfile('shaoen2.mp4') },
  { id: 'yuan', title: '课程视频 03', source: $rawfile('yuan.mp4') }
];

export function videoTime(seconds: number): string {
  const value = Math.max(0, Math.floor(seconds));
  return Math.floor(value / 60).toString().padStart(2, '0') + ':' + (value % 60).toString().padStart(2, '0');
}
