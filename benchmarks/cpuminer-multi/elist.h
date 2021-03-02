#ifndef _LINUX_LIST_H
#define _LINUX_LIST_H

/*
 * Simple doubly linked list implementation.
 *
 * Some of the internal functions ("__xxx") are useful when
 * manipulating whole lists rather than single entries, as
 * sometimes we already know the next/prev entries and we can
 * generate better code by using them directly rather than
 * using the generic single-entry routines.
 */

struct list_head_cpuminer {
	struct list_head_cpuminer *next, *prev;
};

#define LIST_HEAD_INIT(name) { &(name), &(name) }

#define LIST_HEAD(name) \
	struct list_head_cpuminer name = LIST_HEAD_INIT(name)

#define INIT_LIST_HEAD(ptr) do { \
	(ptr)->next = (ptr); (ptr)->prev = (ptr); \
} while (0)

/*
 * Insert a new entry between two known consecutive entries.
 *
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 */
static inline void __list_add_cpuminer(struct list_head_cpuminer *nlh,
			      struct list_head_cpuminer *prev,
			      struct list_head_cpuminer *next)
{
	next->prev = nlh;
	nlh->next = next;
	nlh->prev = prev;
	prev->next = nlh;
}

/**
 * list_add_cpuminer - add a new entry
 * @new: new entry to be added
 * @head: list head to add it after
 *
 * Insert a new entry after the specified head.
 * This is good for implementing stacks.
 */
static inline void list_add_cpuminer(struct list_head_cpuminer *nlh, struct list_head_cpuminer *head)
{
	__list_add_cpuminer(nlh, head, head->next);
}

/**
 * list_add_tail_cpuminer - add a new entry
 * @new: new entry to be added
 * @head: list head to add it before
 *
 * Insert a new entry before the specified head.
 * This is useful for implementing queues.
 */
static inline void list_add_tail_cpuminer(struct list_head_cpuminer *nlh, struct list_head_cpuminer *head)
{
	__list_add_cpuminer(nlh, head->prev, head);
}

/*
 * Delete a list entry by making the prev/next entries
 * point to each other.
 *
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 */
static inline void __list_del_cpuminer(struct list_head_cpuminer *prev, struct list_head_cpuminer *next)
{
	next->prev = prev;
	prev->next = next;
}

/**
 * list_del_cpuminer - deletes entry from list.
 * @entry: the element to delete from the list.
 * Note: list_empty_cpuminer on entry does not return true after this, the entry is in an undefined state.
 */
static inline void list_del_cpuminer(struct list_head_cpuminer *entry)
{
	__list_del_cpuminer(entry->prev, entry->next);
	entry->next = NULL;
	entry->prev = NULL;
}

/**
 * list_del_cpuminer_init - deletes entry from list and reinitialize it.
 * @entry: the element to delete from the list.
 */
static inline void list_del_cpuminer_init(struct list_head_cpuminer *entry)
{
	__list_del_cpuminer(entry->prev, entry->next);
	INIT_LIST_HEAD(entry);
}

/**
 * list_move - delete from one list and add as another's head
 * @list: the entry to move
 * @head: the head that will precede our entry
 */
static inline void list_move(struct list_head_cpuminer *list, struct list_head_cpuminer *head)
{
        __list_del_cpuminer(list->prev, list->next);
        list_add_cpuminer(list, head);
}

/**
 * list_move_tail - delete from one list and add as another's tail
 * @list: the entry to move
 * @head: the head that will follow our entry
 */
static inline void list_move_tail(struct list_head_cpuminer *list,
				  struct list_head_cpuminer *head)
{
        __list_del_cpuminer(list->prev, list->next);
        list_add_tail_cpuminer(list, head);
}

/**
 * list_empty_cpuminer - tests whether a list is empty
 * @head: the list to test.
 */
static inline int list_empty_cpuminer(struct list_head_cpuminer *head)
{
	return head->next == head;
}

static inline void __list_splice(struct list_head_cpuminer *list,
				 struct list_head_cpuminer *head)
{
	struct list_head_cpuminer *first = list->next;
	struct list_head_cpuminer *last = list->prev;
	struct list_head_cpuminer *at = head->next;

	first->prev = head;
	head->next = first;

	last->next = at;
	at->prev = last;
}

/**
 * list_splice - join two lists
 * @list: the new list to add.
 * @head: the place to add it in the first list.
 */
static inline void list_splice(struct list_head_cpuminer *list, struct list_head_cpuminer *head)
{
	if (!list_empty_cpuminer(list))
		__list_splice(list, head);
}

/**
 * list_splice_init - join two lists and reinitialise the emptied list.
 * @list: the new list to add.
 * @head: the place to add it in the first list.
 *
 * The list at @list is reinitialised
 */
static inline void list_splice_init(struct list_head_cpuminer *list,
				    struct list_head_cpuminer *head)
{
	if (!list_empty_cpuminer(list)) {
		__list_splice(list, head);
		INIT_LIST_HEAD(list);
	}
}

/**
 * list_entry - get the struct for this entry
 * @ptr:	the &struct list_head_cpuminer pointer.
 * @type:	the type of the struct this is embedded in.
 * @member:	the name of the list_struct within the struct.
 */
#define list_entry(ptr, type, member) \
	((type *)((char *)(ptr)-(unsigned long)(&((type *)0)->member)))

/**
 * list_for_each	-	iterate over a list
 * @pos:	the &struct list_head_cpuminer to use as a loop counter.
 * @head:	the head for your list.
 */
#define list_for_each(pos, head) \
	for (pos = (head)->next; pos != (head); \
        	pos = pos->next)
/**
 * list_for_each_prev	-	iterate over a list backwards
 * @pos:	the &struct list_head_cpuminer to use as a loop counter.
 * @head:	the head for your list.
 */
#define list_for_each_prev(pos, head) \
	for (pos = (head)->prev; pos != (head); \
        	pos = pos->prev)

/**
 * list_for_each_safe	-	iterate over a list safe against removal of list entry
 * @pos:	the &struct list_head_cpuminer to use as a loop counter.
 * @n:		another &struct list_head_cpuminer to use as temporary storage
 * @head:	the head for your list.
 */
#define list_for_each_safe(pos, n, head) \
	for (pos = (head)->next, n = pos->next; pos != (head); \
		pos = n, n = pos->next)

/**
 * list_for_each_entry	-	iterate over list of given type
 * @pos:	the type * to use as a loop counter.
 * @head:	the head for your list.
 * @member:	the name of the list_struct within the struct.
 * @type:	the type of the struct.
 */
#define list_for_each_entry(pos, head, member, type)			\
	for (pos = list_entry((head)->next, type, member);	\
	     &pos->member != (head); 					\
	     pos = list_entry(pos->member.next, type, member))

/**
 * list_for_each_entry_safe - iterate over list of given type safe against removal of list entry
 * @pos:	the type * to use as a loop counter.
 * @n:		another type * to use as temporary storage
 * @head:	the head for your list.
 * @member:	the name of the list_struct within the struct.
 * @type:	the type of the struct.
 */
#define list_for_each_entry_safe(pos, n, head, member, type)		\
	for (pos = list_entry((head)->next, type, member),	\
		n = list_entry(pos->member.next, type, member);	\
	     &pos->member != (head); 					\
	     pos = n, n = list_entry(n->member.next, type, member))

/**
 * list_for_each_entry_continue -       iterate over list of given type
 *                      continuing after existing point
 * @pos:        the type * to use as a loop counter.
 * @head:       the head for your list.
 * @member:     the name of the list_struct within the struct.
 * @type:       the type of the struct.
 */
#define list_for_each_entry_continue(pos, head, member, type)		\
	for (pos = list_entry(pos->member.next, type, member),	\
		     prefetch(pos->member.next);			\
	     &pos->member != (head);					\
	     pos = list_entry(pos->member.next, type, member),	\
		     prefetch(pos->member.next))

#endif
