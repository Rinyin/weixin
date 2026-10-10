import { Contact, Moment, MomentComment } from '../model/Models';
import { AppStore } from './AppStore';

export interface MomentView {
  moment: Moment;
  name: string;
  avatar: string;
  key: string;
}

export class MomentsService {
  private static saving: boolean = false;

  static list(mineOnly: boolean): MomentView[] {
    const contacts = new Map<string, Contact>();
    AppStore.data.contacts.forEach((contact: Contact) => { contacts.set(contact.id, contact); });
    return AppStore.data.moments.filter((item: Moment) => !mineOnly || item.authorId === 'self')
      .slice().sort((a: Moment, b: Moment) => b.createdAt - a.createdAt)
      .map((item: Moment): MomentView => {
        const contact = contacts.get(item.authorId);
        const name = item.authorId === 'self' ? AppStore.data.profile.name : (contact?.name || '课程朋友');
        const avatar = item.authorId === 'self' ? AppStore.data.profile.avatar : (contact?.avatar || 'avatar1');
        return { moment: item, name: name, avatar: avatar,
          key: item.id + '-' + item.liked.toString() + '-' + item.comments.length.toString() + '-' + name + '-' + avatar + '-' + AppStore.data.profile.name };
      });
  }

  static async publish(text: string, image: string): Promise<void> {
    const content = text.trim().slice(0, 1000);
    if (!content) { throw new Error('请写下想分享的内容'); }
    const item: Moment = { id: AppStore.id('moment'), authorId: 'self', text: content,
      image: ['img1', 'cherry', 'dog'].includes(image) ? image : '', createdAt: Date.now(), liked: false, comments: [] };
    await MomentsService.persist(AppStore.data.moments.concat([item]));
  }

  static async like(id: string): Promise<void> {
    const next = AppStore.data.moments.map((item: Moment): Moment => item.id === id ? {
      id: item.id, authorId: item.authorId, text: item.text, image: item.image, createdAt: item.createdAt,
      liked: !item.liked, comments: item.comments
    } : item);
    await MomentsService.persist(next);
  }

  static async comment(id: string, text: string): Promise<void> {
    const content = text.trim().slice(0, 200);
    if (!content) { throw new Error('评论不能为空'); }
    const comment: MomentComment = { id: AppStore.id('comment'), author: 'self', text: content };
    const next = AppStore.data.moments.map((item: Moment): Moment => item.id === id ? {
      id: item.id, authorId: item.authorId, text: item.text, image: item.image, createdAt: item.createdAt,
      liked: item.liked, comments: item.comments.concat([comment])
    } : item);
    await MomentsService.persist(next);
  }

  private static async persist(next: Moment[]): Promise<void> {
    if (MomentsService.saving) { throw new Error('正在保存，请稍后重试'); }
    MomentsService.saving = true;
    const previous = AppStore.data.moments;
    AppStore.data.moments = next;
    try {
      await AppStore.save();
    } catch {
      AppStore.data.moments = previous;
      throw new Error('保存失败，请检查设备存储后重试');
    } finally { MomentsService.saving = false; }
  }
}
