export interface VideoClip {
  id: string;
  title: string;
  author: string;
  avatar: Resource;
  // 本地示例数据：赞过该视频的好友昵称，用于“朋友”页。
  friendLikes: string[];
  source: Resource;
}

export const VIDEO_CLIPS: VideoClip[] = [
  { id: 'shaoen', title: '小羊肖恩：农场里的新鲜事', author: '动画放映厅', avatar: $r('app.media.doglaugh'), friendLikes: [], source: $rawfile('shaoen.mp4') },
  { id: 'shaoen2', title: '小羊肖恩：又是热闹的一天', author: '动画放映厅', avatar: $r('app.media.doglaugh'), friendLikes: ['敖丙', '哪吒'], source: $rawfile('shaoen2.mp4') },
  { id: 'yuan', title: '火烈鸟的悠闲时光', author: '萌宠动画', avatar: $r('app.media.dog'), friendLikes: ['太乙真人'], source: $rawfile('yuan.mp4') }
];

export function videoTime(seconds: number): string {
  const value = Math.max(0, Math.floor(seconds));
  return Math.floor(value / 60).toString().padStart(2, '0') + ':' + (value % 60).toString().padStart(2, '0');
}
