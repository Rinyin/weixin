export interface ApiResult<T> {
  code: number;
  message: string;
  data?: T | null;
}

export interface LoginRequest {
  phone: string;
  code: string;
}

export interface OnlineProfile {
  nickname: string;
  avatarUrl: string;
}

export enum SessionMode {
  SignedOut = 'signedOut',
  Local = 'local',
  Online = 'online'
}
