import { Button } from '../ui/Button';

interface CustomerPaginationProps {
  page: number;
  totalPages: number;
  totalCount: number;
  perPage: number;
  onPageChange: (page: number) => void;
}

export function CustomerPagination({ page, totalPages, totalCount, perPage, onPageChange }: CustomerPaginationProps) {
  if (totalPages <= 1) return null;

  const start = (page - 1) * perPage + 1;
  const end = Math.min(page * perPage, totalCount);

  // Generate visible page numbers
  const pages: (number | 'ellipsis')[] = [];
  if (totalPages <= 7) {
    for (let i = 1; i <= totalPages; i++) pages.push(i);
  } else {
    pages.push(1);
    if (page > 3) pages.push('ellipsis');
    for (let i = Math.max(2, page - 1); i <= Math.min(totalPages - 1, page + 1); i++) {
      pages.push(i);
    }
    if (page < totalPages - 2) pages.push('ellipsis');
    pages.push(totalPages);
  }

  return (
    <div className="flex items-center justify-between">
      <p className="text-sm text-rough-500">
        Showing <span className="font-medium text-rough-700">{start}</span> to{' '}
        <span className="font-medium text-rough-700">{end}</span> of{' '}
        <span className="font-medium text-rough-700">{totalCount.toLocaleString()}</span> customers
      </p>
      <div className="flex items-center gap-1">
        <Button
          variant="secondary"
          size="sm"
          onClick={() => onPageChange(page - 1)}
          disabled={page <= 1}
        >
          ← Prev
        </Button>
        {pages.map((p, i) =>
          p === 'ellipsis' ? (
            <span key={`e-${i}`} className="px-2 text-rough-400">…</span>
          ) : (
            <button
              key={p}
              onClick={() => onPageChange(p)}
              className={`rounded-md px-3 py-1.5 text-sm font-medium transition-colors ${
                p === page
                  ? 'bg-fairway-600 text-white'
                  : 'text-rough-600 hover:bg-rough-100'
              }`}
            >
              {p}
            </button>
          )
        )}
        <Button
          variant="secondary"
          size="sm"
          onClick={() => onPageChange(page + 1)}
          disabled={page >= totalPages}
        >
          Next →
        </Button>
      </div>
    </div>
  );
}
