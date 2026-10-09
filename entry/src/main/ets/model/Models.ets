export interface Contact {
  id: string;
  name: string;
  account: string;
  avatar: string;
  region: string;
  signature: string;
  initial: string;
}

export interface ChatMessage {
  id: string;
  contactId: string;
  text: string;
  mine: boolean;
  createdAt: number;
}

export interface MomentComment {
  id: string;
  author: string;
  text: string;
}

export interface Moment {
  id: string;
  authorId: string;
  text: string;
  image: string;
  createdAt: number;
  liked: boolean;
  comments: MomentComment[];
}

export interface UserProfile {
  name: string;
  account: string;
  avatar: string;
  region: string;
  signature: string;
}

export interface AppData {
  version: number;
  contacts: Contact[];
  messages: ChatMessage[];
  moments: Moment[];
  profile: UserProfile;
}

export interface ContactRoute {
  contactId: string;
}

export interface MomentsRoute {
  mineOnly: boolean;
}
