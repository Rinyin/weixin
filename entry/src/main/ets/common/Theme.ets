export const GREEN: string = '#07A854';
export const BACKGROUND: string = '#EDEDED';
export const TEXT_PRIMARY: string = '#191919';
export const TEXT_SECONDARY: string = '#777777';
export const LINK_COLOR: string = '#576B95';

export function avatarResource(name: string): Resource {
  switch (name) {
    case 'avatar1': return $r('app.media.avatar1');
    case 'avatar2': return $r('app.media.avatar2');
    case 'avatar3': return $r('app.media.avatar3');
    case 'avatar4': return $r('app.media.avatar4');
    case 'avatar5': return $r('app.media.avatar5');
    case 'avatar6': return $r('app.media.avatar6');
    default: return $r('app.media.avatar7');
  }
}

export function timeLabel(value: number): string {
  const date = new Date(value);
  if (date.toDateString() === new Date().toDateString()) {
    return date.getHours().toString().padStart(2, '0') + ':' + date.getMinutes().toString().padStart(2, '0');
  }
  return (date.getMonth() + 1).toString() + '/' + date.getDate().toString();
}
